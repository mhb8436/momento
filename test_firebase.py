#!/usr/bin/env python3
"""
Firebase 알림 테스트 스크립트

사용 방법:
1. Flutter 앱에서 FCM 토큰을 얻어서 입력
2. 또는 Firebase Console에서 직접 테스트
"""

import asyncio
import sys
from app.services.firebase_service import FirebaseService
from app.models.notification import NotificationType

async def send_test_notification(fcm_token: str):
    """테스트 알림 전송"""
    firebase_service = FirebaseService()
    
    if not firebase_service.is_available():
        print("❌ Firebase 서비스가 초기화되지 않았습니다.")
        return False
    
    try:
        # 테스트 알림 데이터
        notification_data = {
            'title': '🎉 MOMENTO 테스트 알림',
            'body': '레시피 추출 기능이 정상적으로 작동합니다!',
            'data': {
                'type': 'test',
                'message': 'YouTube Shorts URL 추출 완료!'
            }
        }
        
        print(f"📤 알림 전송 중...")
        print(f"🔑 FCM 토큰: {fcm_token[:30]}...{fcm_token[-10:]}")
        
        success = await firebase_service.send_notification(
            tokens=[fcm_token],
            notification_type=NotificationType.APP_UPDATE,
            title=notification_data['title'],
            body=notification_data['body'],
            data=notification_data['data']
        )
        
        if success:
            print("✅ 알림 전송 성공!")
            return True
        else:
            print("❌ 알림 전송 실패")
            return False
            
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        return False

def main():
    print("🔥 Firebase 알림 테스트")
    print("=" * 40)
    
    # FCM 토큰 입력 받기
    print("📱 Flutter 앱에서 FCM 토큰을 복사해서 붙여넣으세요:")
    print("   (앱의 디버그 로그나 개발자 도구에서 확인 가능)")
    print()
    
    fcm_token = input("FCM 토큰: ").strip()
    
    if not fcm_token:
        print("❌ FCM 토큰이 입력되지 않았습니다.")
        print()
        print("💡 대안: Firebase Console에서 직접 테스트")
        print("   1. https://console.firebase.google.com/ 접속")
        print("   2. 프로젝트 선택")
        print("   3. Messaging → 첫 번째 캠페인")
        print("   4. 테스트 메시지 전송")
        sys.exit(1)
    
    # 알림 전송
    result = asyncio.run(send_test_notification(fcm_token))
    
    if result:
        print()
        print("🎊 테스트 완료! 디바이스에서 알림을 확인하세요.")
    else:
        print()
        print("💡 Firebase Console을 통한 테스트도 시도해보세요.")

if __name__ == "__main__":
    main()