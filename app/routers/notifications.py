import json
from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.models import User, FCMToken, NotificationLog, NotificationType
from app.schemas.notification import (
    FCMTokenRegister, FCMTokenResponse, NotificationSend, 
    NotificationBroadcast, NotificationLogResponse, NotificationReadRequest
)
from app.utils.dependencies import get_current_active_user
from app.services.firebase_service import firebase_service

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.post("/register-token", response_model=FCMTokenResponse)
async def register_fcm_token(
    token_data: FCMTokenRegister,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    FCM 토큰을 등록하거나 업데이트합니다.
    """
    # 기존 토큰이 있는지 확인
    stmt = select(FCMToken).where(
        or_(
            FCMToken.token == token_data.fcm_token,
            FCMToken.user_id == current_user.id
        )
    )
    result = await db.execute(stmt)
    existing_token = result.scalar_one_or_none()
    
    if existing_token:
        if existing_token.user_id == current_user.id:
            # 같은 사용자의 토큰 업데이트
            existing_token.token = token_data.fcm_token
            existing_token.device_type = token_data.device_type
            existing_token.is_active = True
            token = existing_token
        else:
            # 다른 사용자가 같은 토큰 사용 중인 경우 비활성화
            existing_token.is_active = False
            
            # 새 토큰 생성
            token = FCMToken(
                user_id=current_user.id,
                token=token_data.fcm_token,
                device_type=token_data.device_type,
            )
            db.add(token)
    else:
        # 새 토큰 생성
        token = FCMToken(
            user_id=current_user.id,
            token=token_data.fcm_token,
            device_type=token_data.device_type,
        )
        db.add(token)
    
    await db.commit()
    await db.refresh(token)
    
    return token


@router.delete("/unregister-token")
async def unregister_fcm_token(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    현재 사용자의 FCM 토큰을 비활성화합니다.
    """
    stmt = select(FCMToken).where(
        and_(
            FCMToken.user_id == current_user.id,
            FCMToken.is_active == True
        )
    )
    result = await db.execute(stmt)
    tokens = result.scalars().all()
    
    for token in tokens:
        token.is_active = False
    
    await db.commit()
    
    return {"message": f"{len(tokens)} FCM 토큰이 비활성화되었습니다."}


@router.get("/logs", response_model=List[NotificationLogResponse])
async def get_notification_logs(
    skip: int = 0,
    limit: int = 50,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    사용자의 알림 로그를 조회합니다.
    """
    stmt = (
        select(NotificationLog)
        .where(NotificationLog.user_id == current_user.id)
        .order_by(NotificationLog.sent_at.desc())
        .offset(skip)
        .limit(limit)
    )
    result = await db.execute(stmt)
    logs = result.scalars().all()
    
    return logs


@router.post("/read")
async def mark_notifications_as_read(
    read_request: NotificationReadRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    알림을 읽음 처리합니다.
    """
    stmt = select(NotificationLog).where(
        and_(
            NotificationLog.id.in_(read_request.notification_ids),
            NotificationLog.user_id == current_user.id,
            NotificationLog.is_read == False
        )
    )
    result = await db.execute(stmt)
    logs = result.scalars().all()
    
    for log in logs:
        log.is_read = True
        log.read_at = datetime.utcnow()
    
    await db.commit()
    
    return {"message": f"{len(logs)} 알림이 읽음 처리되었습니다."}


@router.get("/stats")
async def get_notification_stats(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    사용자의 알림 통계를 조회합니다.
    """
    # 총 알림 수
    total_stmt = select(NotificationLog).where(NotificationLog.user_id == current_user.id)
    total_result = await db.execute(total_stmt)
    total_count = len(total_result.scalars().all())
    
    # 읽지 않은 알림 수
    unread_stmt = select(NotificationLog).where(
        and_(
            NotificationLog.user_id == current_user.id,
            NotificationLog.is_read == False
        )
    )
    unread_result = await db.execute(unread_stmt)
    unread_count = len(unread_result.scalars().all())
    
    return {
        "total_notifications": total_count,
        "unread_notifications": unread_count,
        "read_notifications": total_count - unread_count
    }


# 관리자용 엔드포인트들

@router.post("/send", status_code=status.HTTP_202_ACCEPTED)
async def send_notification_to_users(
    notification: NotificationSend,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    특정 사용자들에게 알림을 발송합니다. (관리자용)
    """
    # TODO: 관리자 권한 체크
    
    # FCM 토큰 조회
    stmt = select(FCMToken).where(
        and_(
            FCMToken.user_id.in_(notification.user_ids),
            FCMToken.is_active == True
        )
    )
    result = await db.execute(stmt)
    tokens = result.scalars().all()
    
    # 알림 로그 저장
    notification_logs = []
    for user_id in notification.user_ids:
        log = NotificationLog(
            user_id=user_id,
            notification_type=notification.notification_type,
            title=notification.title,
            body=notification.body,
            data=json.dumps(notification.data) if notification.data else None
        )
        notification_logs.append(log)
        db.add(log)
    
    await db.commit()
    
    # Firebase를 통한 실제 푸시 알림 발송
    if tokens:
        token_list = [token.token for token in tokens]
        firebase_result = await firebase_service.send_notification_to_tokens(
            tokens=token_list,
            title=notification.title,
            body=notification.body,
            data=notification.data,
            notification_type=notification.notification_type
        )
        
        return {
            "message": f"{len(notification.user_ids)}명의 사용자에게 알림 발송 요청이 처리되었습니다.",
            "fcm_tokens_found": len(tokens),
            "firebase_result": firebase_result
        }
    else:
        return {
            "message": f"{len(notification.user_ids)}명의 사용자에게 알림 발송 요청이 처리되었습니다.",
            "fcm_tokens_found": 0,
            "warning": "활성 FCM 토큰이 없어 실제 알림이 발송되지 않았습니다."
        }


@router.post("/broadcast", status_code=status.HTTP_202_ACCEPTED)
async def broadcast_notification(
    notification: NotificationBroadcast,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    모든 활성 사용자에게 알림을 브로드캐스트합니다. (관리자용)
    """
    # TODO: 관리자 권한 체크
    
    # 모든 활성 사용자 조회
    users_stmt = select(User).where(User.is_active == True)
    users_result = await db.execute(users_stmt)
    users = users_result.scalars().all()
    
    # 알림 로그 저장
    notification_logs = []
    for user in users:
        log = NotificationLog(
            user_id=user.id,
            notification_type=notification.notification_type,
            title=notification.title,
            body=notification.body,
            data=json.dumps(notification.data) if notification.data else None
        )
        notification_logs.append(log)
        db.add(log)
    
    await db.commit()
    
    # Firebase를 통한 실제 푸시 알림 발송 (토픽 사용)
    firebase_result = await firebase_service.send_notification_to_topic(
        topic="all_users",  # 모든 사용자를 위한 기본 토픽
        title=notification.title,
        body=notification.body,
        data=notification.data,
        notification_type=notification.notification_type
    )
    
    return {
        "message": f"전체 {len(users)}명의 사용자에게 알림 브로드캐스트 요청이 처리되었습니다.",
        "firebase_result": firebase_result
    }


@router.post("/test")
async def send_test_notification(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    현재 사용자에게 테스트 알림을 발송합니다.
    """
    # 사용자의 FCM 토큰 조회
    tokens_stmt = select(FCMToken).where(
        and_(
            FCMToken.user_id == current_user.id,
            FCMToken.is_active == True
        )
    )
    
    tokens_result = await db.execute(tokens_stmt)
    tokens = tokens_result.scalars().all()
    
    if not tokens:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="등록된 FCM 토큰이 없습니다. 앱을 다시 시작해주세요."
        )
    
    # 테스트 알림 데이터
    test_data = {
        'type': 'test',
        'message': '🎉 Firebase 연결이 정상적으로 작동합니다!',
        'timestamp': datetime.now().isoformat()
    }
    
    # Firebase를 통한 알림 발송
    token_strings = [token.token for token in tokens]
    firebase_result = await firebase_service.send_notification(
        tokens=token_strings,
        notification_type=NotificationType.APP_UPDATE,
        title="🔥 MOMENTO 테스트 알림",
        body="YouTube URL 추출 및 Firebase 알림이 정상 작동합니다!",
        data=test_data
    )
    
    # 알림 로그 저장
    log = NotificationLog(
        user_id=current_user.id,
        notification_type=NotificationType.APP_UPDATE,
        title="🔥 MOMENTO 테스트 알림",
        body="YouTube URL 추출 및 Firebase 알림이 정상 작동합니다!",
        data=json.dumps(test_data)
    )
    db.add(log)
    await db.commit()
    
    return {
        "message": f"{len(tokens)}개의 디바이스로 테스트 알림을 발송했습니다.",
        "tokens_count": len(tokens),
        "firebase_result": firebase_result,
        "user_name": current_user.full_name or current_user.email
    }