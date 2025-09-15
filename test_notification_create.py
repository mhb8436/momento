#!/usr/bin/env python3
"""
SQLAdmin NotificationAdmin 생성 기능 테스트
"""

import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import async_engine
from app.models.notification import NotificationLog, NotificationType
from app.models.user import User


async def test_notification_creation():
    """알림 생성 기능 테스트"""
    async with AsyncSession(async_engine) as session:
        try:
            # 활성 사용자 수 확인
            result = await session.execute(
                select(User).where(User.is_active == True)
            )
            users = result.scalars().all()
            print(f"📊 활성 사용자 수: {len(users)}명")
            
            for user in users:
                print(f"   • {user.email} (ID: {user.id})")
            
            # 기존 알림 로그 수 확인
            result = await session.execute(select(NotificationLog))
            notifications = result.scalars().all()
            print(f"📋 기존 알림 로그 수: {len(notifications)}개")
            
            print("\n✅ SQLAdmin에서 알림 생성 테스트를 위한 준비 완료!")
            print("🌐 브라우저에서 다음 단계를 수행하세요:")
            print("1. http://localhost:8000/admin/ 접속")
            print("2. 로그인 (admin@test.com / testpass123)")
            print("3. 좌측 메뉴에서 '알림 관리' 클릭")
            print("4. 'New Notification Log' 버튼 클릭")
            print("5. 폼 작성 후 저장")
            print("\n폼 예시:")
            print("  - 제목: 테스트 알림")
            print("  - 내용: SQLAdmin에서 생성한 테스트 알림입니다")
            print("  - 알림 유형: general")
            print("  - 사용자 ID: (비워두면 전체 발송)")
            
        except Exception as e:
            print(f"❌ 테스트 실행 실패: {e}")


if __name__ == "__main__":
    asyncio.run(test_notification_creation())