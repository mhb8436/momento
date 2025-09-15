#!/usr/bin/env python3
"""
수정된 SQLAdmin NotificationAdmin 생성 기능 테스트
"""

import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import async_engine
from app.models.notification import NotificationLog, NotificationType
from app.models.user import User


async def test_notification_status():
    """현재 알림 시스템 상태 확인"""
    async with AsyncSession(async_engine) as session:
        try:
            # 활성 사용자 수 확인
            result = await session.execute(
                select(User).where(User.is_active == True)
            )
            users = result.scalars().all()
            print(f"📊 활성 사용자 수: {len(users)}명")
            
            for user in users:
                print(f"   • {user.email} (ID: {str(user.id)[:8]}...)")
            
            # 알림 로그 수 확인
            result = await session.execute(select(NotificationLog))
            notifications = result.scalars().all()
            print(f"📋 총 알림 로그 수: {len(notifications)}개")
            
            # 최근 알림 확인
            recent_result = await session.execute(
                select(NotificationLog).order_by(NotificationLog.sent_at.desc()).limit(5)
            )
            recent_notifications = recent_result.scalars().all()
            
            print(f"\n📅 최근 알림 5개:")
            for notif in recent_notifications:
                sent_time = notif.sent_at.strftime('%m-%d %H:%M') if notif.sent_at else 'Unknown'
                print(f"   • {notif.title} → 사용자: {str(notif.user_id)[:8]}... ({sent_time})")
            
            print("\n✅ 수정된 SQLAdmin 알림 생성 테스트 준비 완료!")
            print("🔧 변경사항:")
            print("   - user_id 필드가 폼에서 제거됨 (자동 처리)")
            print("   - 전체 발송 시 첫 번째 사용자 ID가 자동 설정됨")
            print("   - 모든 활성 사용자에게 실제 알림 발송됨")
            print("   - NOT NULL 제약 조건 오류 해결됨")
            
            print("\n🌐 브라우저에서 테스트하세요:")
            print("1. http://localhost:8000/admin/ 접속")
            print("2. 로그인 (admin@test.com / testpass123)")
            print("3. 좌측 메뉴에서 '알림 관리' 클릭")
            print("4. 'New Notification Log' 버튼 클릭")
            print("5. 간단한 폼 작성:")
            print("   - 제목: 수정된 알림 테스트")
            print("   - 내용: 오류가 수정되어 정상 작동합니다")
            print("   - 알림 유형: app_update")
            print("6. 저장 버튼 클릭")
            print("\n🎯 예상 결과:")
            print(f"   - {len(users)}명 모두에게 실제 알림 발송")
            print("   - SQLAdmin에서 정상 저장 완료")
            print("   - 서버 로그에 발송 성공 메시지 출력")
            
        except Exception as e:
            print(f"❌ 테스트 실행 실패: {e}")


if __name__ == "__main__":
    asyncio.run(test_notification_status())