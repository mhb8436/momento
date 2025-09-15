import json
from typing import List, Optional, Dict, Any
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_

from app.models.user import User
from app.models.notification import FCMToken, NotificationLog, NotificationType
from app.services.firebase_service import firebase_service


class NotificationService:
    """알림 발송을 위한 서비스 클래스"""
    
    def __init__(self, db: AsyncSession):
        self.db = db

    async def send_notification(
        self,
        user_id: str,
        title: str,
        body: str,
        notification_type: str = "app_update",
        data: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """특정 사용자에게 알림 발송"""
        try:
            # NotificationType enum으로 변환
            notification_type_enum = NotificationType(notification_type)
        except ValueError:
            notification_type_enum = NotificationType.APP_UPDATE
        
        # 사용자의 활성 FCM 토큰 조회
        tokens_stmt = select(FCMToken).where(
            and_(
                FCMToken.user_id == user_id,
                FCMToken.is_active == True
            )
        )
        tokens_result = await self.db.execute(tokens_stmt)
        tokens = tokens_result.scalars().all()
        
        # 알림 로그 저장
        log = NotificationLog(
            user_id=user_id,
            notification_type=notification_type_enum,
            title=title,
            body=body,
            data=json.dumps(data) if data else None
        )
        self.db.add(log)
        await self.db.commit()
        
        # Firebase를 통한 실제 푸시 알림 발송
        if tokens:
            token_list = [token.token for token in tokens]
            firebase_result = await firebase_service.send_notification_to_tokens(
                tokens=token_list,
                title=title,
                body=body,
                data=data,
                notification_type=notification_type_enum
            )
            
            return {
                "success": True,
                "message": f"사용자 {user_id}에게 알림 발송 완료",
                "fcm_tokens_found": len(tokens),
                "firebase_result": firebase_result
            }
        else:
            return {
                "success": False,
                "message": f"사용자 {user_id}의 활성 FCM 토큰이 없습니다",
                "fcm_tokens_found": 0
            }

    async def broadcast_notification(
        self,
        title: str,
        body: str,
        notification_type: str = "app_update",
        data: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """모든 활성 사용자에게 알림 브로드캐스트"""
        try:
            notification_type_enum = NotificationType(notification_type)
        except ValueError:
            notification_type_enum = NotificationType.APP_UPDATE
        
        # 모든 활성 사용자 조회
        users_stmt = select(User).where(User.is_active == True)
        users_result = await self.db.execute(users_stmt)
        users = users_result.scalars().all()
        
        # 알림 로그 저장
        notification_logs = []
        for user in users:
            log = NotificationLog(
                user_id=user.id,
                notification_type=notification_type_enum,
                title=title,
                body=body,
                data=json.dumps(data) if data else None
            )
            notification_logs.append(log)
            self.db.add(log)
        
        await self.db.commit()
        
        # Firebase를 통한 실제 푸시 알림 발송 (토픽 사용)
        firebase_result = await firebase_service.send_notification_to_topic(
            topic="all_users",
            title=title,
            body=body,
            data=data,
            notification_type=notification_type_enum
        )
        
        return {
            "success": True,
            "message": f"전체 {len(users)}명의 사용자에게 알림 브로드캐스트 완료",
            "users_count": len(users),
            "firebase_result": firebase_result
        }

    async def get_user_notification_stats(self, user_id: str) -> Dict[str, int]:
        """사용자의 알림 통계 조회"""
        # 총 알림 수
        total_stmt = select(NotificationLog).where(NotificationLog.user_id == user_id)
        total_result = await self.db.execute(total_stmt)
        total_count = len(total_result.scalars().all())
        
        # 읽지 않은 알림 수
        unread_stmt = select(NotificationLog).where(
            and_(
                NotificationLog.user_id == user_id,
                NotificationLog.is_read == False
            )
        )
        unread_result = await self.db.execute(unread_stmt)
        unread_count = len(unread_result.scalars().all())
        
        return {
            "total_notifications": total_count,
            "unread_notifications": unread_count,
            "read_notifications": total_count - unread_count
        }