import json
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_
from sqlalchemy.orm import selectinload
from typing import List, Optional
from datetime import datetime

from app.database import get_db
from app.models.user import User
from app.models.inquiry import Inquiry, InquiryStatus, InquiryCategory
from app.models.notification import FCMToken, NotificationLog, NotificationType
from app.schemas.inquiry import (
    InquiryCreate, InquiryUpdate, InquiryResponse, InquiryListResponse,
    AdminResponseCreate, AdminResponseUpdate, InquiryStatsResponse
)
from app.utils.dependencies import get_current_active_user
from app.services.firebase_service import firebase_service

# router = APIRouter(prefix="/inquiries", tags=["inquiries"])
router = APIRouter()

@router.post("/", response_model=InquiryResponse)
async def create_inquiry(
    inquiry: InquiryCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """문의사항 작성"""
    db_inquiry = Inquiry(
        user_id=current_user.id,
        title=inquiry.title,
        content=inquiry.content,
        category=inquiry.category,
        status=InquiryStatus.PENDING
    )
    
    db.add(db_inquiry)
    await db.commit()
    await db.refresh(db_inquiry)
    
    return InquiryResponse(
        id=str(db_inquiry.id),
        user_id=str(db_inquiry.user_id),
        title=db_inquiry.title,
        content=db_inquiry.content,
        category=db_inquiry.category,
        status=db_inquiry.status,
        admin_response=db_inquiry.admin_response,
        admin_response_at=db_inquiry.admin_response_at,
        admin_id=str(db_inquiry.admin_id) if db_inquiry.admin_id else None,
        created_at=db_inquiry.created_at,
        updated_at=db_inquiry.updated_at
    )


@router.get("/", response_model=List[InquiryListResponse])
async def get_user_inquiries(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
    status_filter: Optional[InquiryStatus] = Query(None, description="상태별 필터"),
    category_filter: Optional[InquiryCategory] = Query(None, description="카테고리별 필터"),
    skip: int = Query(0, ge=0, description="건너뛸 항목 수"),
    limit: int = Query(20, ge=1, le=100, description="가져올 항목 수")
):
    """사용자의 문의사항 목록 조회"""
    query = select(Inquiry).where(Inquiry.user_id == current_user.id)
    
    if status_filter:
        query = query.where(Inquiry.status == status_filter)
    
    if category_filter:
        query = query.where(Inquiry.category == category_filter)
    
    query = query.order_by(Inquiry.created_at.desc()).offset(skip).limit(limit)
    
    result = await db.execute(query)
    inquiries = result.scalars().all()
    
    return [
        InquiryListResponse(
            id=str(inquiry.id),
            title=inquiry.title,
            category=inquiry.category,
            status=inquiry.status,
            created_at=inquiry.created_at,
            updated_at=inquiry.updated_at,
            has_response=bool(inquiry.admin_response)
        )
        for inquiry in inquiries
    ]


@router.get("/stats", response_model=InquiryStatsResponse)
async def get_user_inquiry_stats(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """사용자의 문의사항 통계"""
    # 전체 문의사항 수
    total_query = select(func.count(Inquiry.id)).where(Inquiry.user_id == current_user.id)
    total_result = await db.execute(total_query)
    total = total_result.scalar() or 0
    
    # 상태별 문의사항 수
    pending_query = select(func.count(Inquiry.id)).where(
        and_(Inquiry.user_id == current_user.id, Inquiry.status == InquiryStatus.PENDING)
    )
    pending_result = await db.execute(pending_query)
    pending = pending_result.scalar() or 0
    
    answered_query = select(func.count(Inquiry.id)).where(
        and_(Inquiry.user_id == current_user.id, Inquiry.status == InquiryStatus.ANSWERED)
    )
    answered_result = await db.execute(answered_query)
    answered = answered_result.scalar() or 0
    
    closed_query = select(func.count(Inquiry.id)).where(
        and_(Inquiry.user_id == current_user.id, Inquiry.status == InquiryStatus.CLOSED)
    )
    closed_result = await db.execute(closed_query)
    closed = closed_result.scalar() or 0
    
    return InquiryStatsResponse(
        total=total,
        pending=pending,
        answered=answered,
        closed=closed
    )


@router.get("/{inquiry_id}", response_model=InquiryResponse)
async def get_inquiry(
    inquiry_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """문의사항 상세 조회"""
    query = select(Inquiry).where(
        and_(Inquiry.id == inquiry_id, Inquiry.user_id == current_user.id)
    )
    result = await db.execute(query)
    inquiry = result.scalar_one_or_none()
    
    if not inquiry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="문의사항을 찾을 수 없습니다"
        )
    
    return InquiryResponse(
        id=str(inquiry.id),
        user_id=str(inquiry.user_id),
        title=inquiry.title,
        content=inquiry.content,
        category=inquiry.category,
        status=inquiry.status,
        admin_response=inquiry.admin_response,
        admin_response_at=inquiry.admin_response_at,
        admin_id=str(inquiry.admin_id) if inquiry.admin_id else None,
        created_at=inquiry.created_at,
        updated_at=inquiry.updated_at
    )


@router.put("/{inquiry_id}", response_model=InquiryResponse)
async def update_inquiry(
    inquiry_id: str,
    inquiry_update: InquiryUpdate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """문의사항 수정 (답변이 달리기 전에만 가능)"""
    query = select(Inquiry).where(
        and_(Inquiry.id == inquiry_id, Inquiry.user_id == current_user.id)
    )
    result = await db.execute(query)
    inquiry = result.scalar_one_or_none()
    
    if not inquiry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="문의사항을 찾을 수 없습니다"
        )
    
    # 답변이 달린 문의사항은 수정 불가
    if inquiry.status != InquiryStatus.PENDING:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="답변이 완료된 문의사항은 수정할 수 없습니다"
        )
    
    # 업데이트할 필드가 있는지 확인
    update_data = inquiry_update.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="업데이트할 필드가 없습니다"
        )
    
    # 필드 업데이트
    for field, value in update_data.items():
        setattr(inquiry, field, value)
    
    inquiry.updated_at = datetime.utcnow()
    
    await db.commit()
    await db.refresh(inquiry)
    
    return InquiryResponse(
        id=str(inquiry.id),
        user_id=str(inquiry.user_id),
        title=inquiry.title,
        content=inquiry.content,
        category=inquiry.category,
        status=inquiry.status,
        admin_response=inquiry.admin_response,
        admin_response_at=inquiry.admin_response_at,
        admin_id=str(inquiry.admin_id) if inquiry.admin_id else None,
        created_at=inquiry.created_at,
        updated_at=inquiry.updated_at
    )


@router.delete("/{inquiry_id}")
async def delete_inquiry(
    inquiry_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """문의사항 삭제 (답변이 달리기 전에만 가능)"""
    query = select(Inquiry).where(
        and_(Inquiry.id == inquiry_id, Inquiry.user_id == current_user.id)
    )
    result = await db.execute(query)
    inquiry = result.scalar_one_or_none()
    
    if not inquiry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="문의사항을 찾을 수 없습니다"
        )
    
    # 답변이 달린 문의사항은 삭제 불가
    if inquiry.status != InquiryStatus.PENDING:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="답변이 완료된 문의사항은 삭제할 수 없습니다"
        )
    
    await db.delete(inquiry)
    await db.commit()
    
    return {"success": True, "message": "문의사항이 삭제되었습니다"}


# 관리자용 API (향후 관리자 권한 체크 추가 필요)
@router.post("/{inquiry_id}/response", response_model=InquiryResponse)
async def create_admin_response(
    inquiry_id: str,
    response: AdminResponseCreate,
    current_user: User = Depends(get_current_active_user),  # 향후 관리자 권한 체크로 변경
    db: AsyncSession = Depends(get_db)
):
    """관리자 답변 작성"""
    query = select(Inquiry).where(Inquiry.id == inquiry_id)
    result = await db.execute(query)
    inquiry = result.scalar_one_or_none()
    
    if not inquiry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="문의사항을 찾을 수 없습니다"
        )
    
    # 답변 작성
    inquiry.admin_response = response.admin_response
    inquiry.admin_response_at = datetime.utcnow()
    inquiry.admin_id = current_user.id
    inquiry.status = InquiryStatus.ANSWERED
    inquiry.updated_at = datetime.utcnow()
    
    await db.commit()
    await db.refresh(inquiry)
    
    # 문의사항 답변 알림 발송
    try:
        # 사용자의 FCM 토큰 조회
        fcm_query = select(FCMToken).where(
            and_(
                FCMToken.user_id == inquiry.user_id,
                FCMToken.is_active == True
            )
        )
        fcm_result = await db.execute(fcm_query)
        fcm_tokens = fcm_result.scalars().all()
        
        if fcm_tokens:
            token_list = [token.token for token in fcm_tokens]
            await firebase_service.send_notification_to_tokens(
                tokens=token_list,
                title="문의사항 답변 도착",
                body=f"'{inquiry.title}' 문의에 대한 답변이 도착했습니다.",
                data={
                    "inquiry_id": str(inquiry.id),
                    "inquiry_title": inquiry.title
                },
                notification_type=NotificationType.INQUIRY_ANSWER
            )
        
        # 알림 로그 저장
        notification_log = NotificationLog(
            user_id=inquiry.user_id,
            notification_type=NotificationType.INQUIRY_ANSWER,
            title="문의사항 답변 도착",
            body=f"'{inquiry.title}' 문의에 대한 답변이 도착했습니다.",
            data=json.dumps({
                "inquiry_id": str(inquiry.id),
                "inquiry_title": inquiry.title
            })
        )
        db.add(notification_log)
        await db.commit()
        
    except Exception as e:
        print(f"❌ 문의사항 답변 알림 발송 실패: {e}")
        # 알림 실패는 메인 기능에 영향을 주지 않도록 처리
    
    return InquiryResponse(
        id=str(inquiry.id),
        user_id=str(inquiry.user_id),
        title=inquiry.title,
        content=inquiry.content,
        category=inquiry.category,
        status=inquiry.status,
        admin_response=inquiry.admin_response,
        admin_response_at=inquiry.admin_response_at,
        admin_id=str(inquiry.admin_id) if inquiry.admin_id else None,
        created_at=inquiry.created_at,
        updated_at=inquiry.updated_at
    )