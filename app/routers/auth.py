from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from fastapi.security import HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models.user import User
from app.schemas.auth import UserCreate, UserLogin, UserResponse, UserUpdate, Token, PasswordChangeRequest, AccountDeletionRequest
from app.utils.security import verify_password, get_password_hash, create_access_token
from app.utils.dependencies import get_current_active_user
from app.config import settings

router = APIRouter()
security = HTTPBearer()


@router.post("/signup", response_model=UserResponse)
async def create_user(user: UserCreate, db: AsyncSession = Depends(get_db)):
    # Check if user already exists
    result = await db.execute(select(User).where(User.email == user.email))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user.password)
    db_user = User(
        email=user.email,
        password_hash=hashed_password,
        full_name=user.full_name
    )
    
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    
    return UserResponse(
        id=str(db_user.id),
        email=db_user.email,
        full_name=db_user.full_name,
        profile_image_url=db_user.profile_image_url,
        is_active=db_user.is_active
    )


@router.post("/login", response_model=Token)
async def login_for_access_token(user_credentials: UserLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == user_credentials.email))
    user = result.scalar_one_or_none()
    
    if not user or not verify_password(user_credentials.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = create_access_token(
        data={"sub": str(user.id)}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/me", response_model=UserResponse)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return UserResponse(
        id=str(current_user.id),
        email=current_user.email,
        full_name=current_user.full_name,
        profile_image_url=current_user.profile_image_url,
        is_active=current_user.is_active
    )


@router.put("/me", response_model=UserResponse)
async def update_user_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """사용자 프로필 업데이트"""
    
    # 업데이트할 필드가 있는지 확인
    update_data = user_update.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="업데이트할 필드가 없습니다"
        )
    
    # 사용자 정보 업데이트
    for field, value in update_data.items():
        setattr(current_user, field, value)
    
    await db.commit()
    await db.refresh(current_user)
    
    return UserResponse(
        id=str(current_user.id),
        email=current_user.email,
        full_name=current_user.full_name,
        profile_image_url=current_user.profile_image_url,
        is_active=current_user.is_active
    )


@router.post("/profile-image", response_model=UserResponse)
async def upload_profile_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """프로필 이미지 업로드"""
    
    # 파일 타입 검증
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="이미지 파일만 업로드 가능합니다"
        )
    
    try:
        # 프로필 이미지 전용 저장 서비스 사용
        from app.services.storage import save_profile_image
        
        file_path, file_name, file_size = await save_profile_image(file, str(current_user.id))
        
        # 이미지 URL 생성 (uploads 라우터에서 서빙)
        profile_image_url = f"/uploads/profiles/{file_name}"
        
        # 사용자 프로필 이미지 URL 업데이트
        current_user.profile_image_url = profile_image_url
        await db.commit()
        await db.refresh(current_user)
        
        return UserResponse(
            id=str(current_user.id),
            email=current_user.email,
            full_name=current_user.full_name,
            profile_image_url=current_user.profile_image_url,
            is_active=current_user.is_active
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"프로필 이미지 업로드 실패: {str(e)}"
        )


@router.post("/change-password")
async def change_password(
    password_data: PasswordChangeRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """비밀번호 변경"""
    
    # 현재 비밀번호 확인
    if not verify_password(password_data.current_password, current_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="현재 비밀번호가 올바르지 않습니다"
        )
    
    # 새 비밀번호 유효성 검사
    if len(password_data.new_password) < 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="새 비밀번호는 최소 6자 이상이어야 합니다"
        )
    
    if password_data.current_password == password_data.new_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="새 비밀번호는 현재 비밀번호와 달라야 합니다"
        )
    
    try:
        # 비밀번호 해시화 및 업데이트
        new_password_hash = get_password_hash(password_data.new_password)
        current_user.password_hash = new_password_hash
        
        await db.commit()
        
        return {"success": True, "message": "비밀번호가 성공적으로 변경되었습니다"}
        
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"비밀번호 변경 실패: {str(e)}"
        )


@router.post("/delete-account")
async def delete_account(
    deletion_data: AccountDeletionRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """계정 탈퇴"""
    
    # 비밀번호 확인
    if not verify_password(deletion_data.password, current_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="비밀번호가 올바르지 않습니다"
        )
    
    # 확인 문구 검증
    if deletion_data.confirmation != "DELETE":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="계정 삭제 확인 문구가 올바르지 않습니다"
        )
    
    try:
        # 사용자와 관련된 모든 데이터 삭제 (CASCADE로 자동 처리됨)
        await db.delete(current_user)
        await db.commit()
        
        return {"success": True, "message": "계정이 성공적으로 삭제되었습니다"}
        
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"계정 삭제 실패: {str(e)}"
        )