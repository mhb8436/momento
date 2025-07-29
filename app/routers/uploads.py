from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from PIL import Image
import os
import uuid
import shutil
from pathlib import Path
from typing import Optional

from app.database import get_db
from app.utils.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/uploads", tags=["uploads"])

# 업로드 디렉토리 설정
UPLOAD_DIR = Path("uploads")
IMAGES_DIR = UPLOAD_DIR / "images"

# 디렉토리 생성
UPLOAD_DIR.mkdir(exist_ok=True)
IMAGES_DIR.mkdir(exist_ok=True)

# 허용된 이미지 확장자
ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB


def validate_image(file: UploadFile) -> bool:
    """이미지 파일 유효성 검사"""
    # 파일 확장자 검사
    if not file.filename:
        return False
    
    ext = Path(file.filename).suffix.lower()
    if ext not in ALLOWED_EXTENSIONS:
        return False
    
    # MIME 타입 검사
    if not file.content_type or not file.content_type.startswith("image/"):
        return False
    
    return True


def resize_image(image_path: Path, max_size: tuple = (1024, 1024)) -> None:
    """이미지 크기 조정"""
    try:
        with Image.open(image_path) as img:
            # EXIF 회전 정보 적용
            img = img.rotate(0, expand=True)
            
            # 크기 조정 (비율 유지)
            img.thumbnail(max_size, Image.LANCZOS)
            
            # JPEG로 저장 (용량 최적화)
            if img.mode in ("RGBA", "P"):
                img = img.convert("RGB")
            
            img.save(image_path, "JPEG", quality=85, optimize=True)
    except Exception as e:
        print(f"이미지 리사이징 오류: {e}")
        raise


@router.post("/recipe-image")
async def upload_recipe_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user)
):
    """레시피 이미지 업로드"""
    
    # 파일 유효성 검사
    if not validate_image(file):
        raise HTTPException(
            status_code=400,
            detail="지원하지 않는 파일 형식입니다. JPG, PNG, WEBP 파일만 업로드 가능합니다."
        )
    
    # 파일 크기 검사
    if file.size and file.size > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail="파일 크기가 너무 큽니다. 10MB 이하의 파일만 업로드 가능합니다."
        )
    
    try:
        # 고유한 파일명 생성
        file_id = str(uuid.uuid4())
        file_extension = ".jpg"  # 모든 이미지를 JPEG로 저장
        filename = f"{file_id}{file_extension}"
        file_path = IMAGES_DIR / filename
        
        # 파일 저장
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        # 이미지 리사이징
        resize_image(file_path)
        
        # 파일 URL 생성
        image_url = f"/uploads/images/{filename}"
        
        return {
            "success": True,
            "image_url": image_url,
            "filename": filename,
            "message": "이미지가 성공적으로 업로드되었습니다."
        }
        
    except Exception as e:
        # 업로드 실패 시 파일 삭제
        if file_path.exists():
            file_path.unlink()
        
        print(f"이미지 업로드 오류: {e}")
        raise HTTPException(
            status_code=500,
            detail="이미지 업로드 중 오류가 발생했습니다."
        )


@router.get("/images/{filename}")
async def get_image(filename: str):
    """이미지 파일 조회"""
    file_path = IMAGES_DIR / filename
    
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="이미지를 찾을 수 없습니다.")
    
    return FileResponse(
        path=file_path, 
        media_type="image/jpeg",
        headers={"Cache-Control": "max-age=86400"}  # 1일 캐시
    )


@router.delete("/images/{filename}")
async def delete_image(
    filename: str,
    current_user: User = Depends(get_current_user)
):
    """이미지 파일 삭제"""
    file_path = IMAGES_DIR / filename
    
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="이미지를 찾을 수 없습니다.")
    
    try:
        file_path.unlink()
        return {"success": True, "message": "이미지가 삭제되었습니다."}
    except Exception as e:
        print(f"이미지 삭제 오류: {e}")
        raise HTTPException(
            status_code=500,
            detail="이미지 삭제 중 오류가 발생했습니다."
        )