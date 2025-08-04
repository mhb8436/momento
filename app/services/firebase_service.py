import os
import json
import logging
from typing import List, Dict, Any, Optional
from firebase_admin import messaging, initialize_app, credentials
from firebase_admin.messaging import Message, Notification, AndroidConfig, APNSConfig
import firebase_admin

from app.models.notification import NotificationType

logger = logging.getLogger(__name__)


class FirebaseService:
    _instance = None
    _initialized = False

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(FirebaseService, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        if not self._initialized:
            self.initialize_firebase()
            self._initialized = True

    def initialize_firebase(self):
        """Firebase Admin SDK 초기화"""
        try:
            # 이미 초기화되어 있는지 확인
            if firebase_admin._apps:
                logger.info("Firebase Admin SDK가 이미 초기화되어 있습니다.")
                return

            service_account_path = os.getenv('FIREBASE_SERVICE_ACCOUNT_PATH')
            if not service_account_path or not os.path.exists(service_account_path):
                logger.warning(f"Firebase 서비스 계정 파일을 찾을 수 없습니다: {service_account_path}")
                return

            # Firebase Admin SDK 초기화
            cred = credentials.Certificate(service_account_path)
            initialize_app(cred)
            logger.info("Firebase Admin SDK 초기화 완료")

        except Exception as e:
            logger.error(f"Firebase Admin SDK 초기화 실패: {e}")

    def is_available(self) -> bool:
        """Firebase 서비스 사용 가능 여부 확인"""
        return bool(firebase_admin._apps)

    async def send_notification_to_tokens(
        self,
        tokens: List[str],
        title: str,
        body: str,
        data: Optional[Dict[str, Any]] = None,
        notification_type: Optional[NotificationType] = None
    ) -> Dict[str, Any]:
        """특정 FCM 토큰들에게 알림 발송"""
        if not self.is_available():
            logger.warning("Firebase 서비스를 사용할 수 없습니다")
            return {
                "success": False,
                "message": "Firebase 서비스를 사용할 수 없습니다",
                "sent_count": 0,
                "failed_count": len(tokens)
            }

        if not tokens:
            return {
                "success": True,
                "message": "발송할 토큰이 없습니다",
                "sent_count": 0,
                "failed_count": 0
            }

        try:
            # 알림 데이터 준비
            notification_data = {}
            if data:
                # 모든 값을 문자열로 변환 (FCM 요구사항)
                notification_data = {k: str(v) for k, v in data.items()}
            
            if notification_type:
                notification_data['notification_type'] = notification_type.value

            # 메시지 생성
            message = Message(
                notification=Notification(
                    title=title,
                    body=body
                ),
                data=notification_data,
                android=AndroidConfig(
                    notification=messaging.AndroidNotification(
                        icon='ic_notification',
                        color='#FF6B35',  # 앱 테마 색상
                        channel_id='momento_notifications'
                    )
                ),
                apns=APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            badge=1,
                            sound='default'
                        )
                    )
                )
            )

            # 배치로 알림 발송
            response = messaging.send_multicast(
                messaging.MulticastMessage(
                    tokens=tokens,
                    notification=message.notification,
                    data=message.data,
                    android=message.android,
                    apns=message.apns
                )
            )

            success_count = response.success_count
            failure_count = response.failure_count

            # 실패한 토큰들 로깅
            if failure_count > 0:
                failed_tokens = []
                for idx, resp in enumerate(response.responses):
                    if not resp.success:
                        failed_tokens.append({
                            'token': tokens[idx][:20] + '...',  # 보안을 위해 일부만 로깅
                            'error': str(resp.exception)
                        })
                logger.warning(f"알림 발송 실패한 토큰들: {failed_tokens}")

            logger.info(f"알림 발송 완료 - 성공: {success_count}, 실패: {failure_count}")

            return {
                "success": success_count > 0,
                "message": f"알림 발송 완료 - 성공: {success_count}, 실패: {failure_count}",
                "sent_count": success_count,
                "failed_count": failure_count,
                "response_details": {
                    "success_count": success_count,
                    "failure_count": failure_count
                }
            }

        except Exception as e:
            logger.error(f"알림 발송 중 오류 발생: {e}")
            return {
                "success": False,
                "message": f"알림 발송 실패: {str(e)}",
                "sent_count": 0,
                "failed_count": len(tokens)
            }

    async def send_notification_to_topic(
        self,
        topic: str,
        title: str,
        body: str,
        data: Optional[Dict[str, Any]] = None,
        notification_type: Optional[NotificationType] = None
    ) -> Dict[str, Any]:
        """특정 주제(토픽)에 알림 발송"""
        if not self.is_available():
            logger.warning("Firebase 서비스를 사용할 수 없습니다")
            return {
                "success": False,
                "message": "Firebase 서비스를 사용할 수 없습니다"
            }

        try:
            # 알림 데이터 준비
            notification_data = {}
            if data:
                notification_data = {k: str(v) for k, v in data.items()}
            
            if notification_type:
                notification_data['notification_type'] = notification_type.value

            # 메시지 생성
            message = Message(
                topic=topic,
                notification=Notification(
                    title=title,
                    body=body
                ),
                data=notification_data,
                android=AndroidConfig(
                    notification=messaging.AndroidNotification(
                        icon='ic_notification',
                        color='#FF6B35',
                        channel_id='momento_notifications'
                    )
                ),
                apns=APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            badge=1,
                            sound='default'
                        )
                    )
                )
            )

            # 알림 발송
            response = messaging.send(message)
            logger.info(f"토픽 알림 발송 완료: {response}")

            return {
                "success": True,
                "message": f"토픽 '{topic}'에 알림 발송 완료",
                "message_id": response
            }

        except Exception as e:
            logger.error(f"토픽 알림 발송 중 오류 발생: {e}")
            return {
                "success": False,
                "message": f"토픽 알림 발송 실패: {str(e)}"
            }

    async def subscribe_to_topic(self, tokens: List[str], topic: str) -> Dict[str, Any]:
        """FCM 토큰들을 특정 주제에 구독"""
        if not self.is_available():
            return {
                "success": False,
                "message": "Firebase 서비스를 사용할 수 없습니다"
            }

        try:
            response = messaging.subscribe_to_topic(tokens, topic)
            logger.info(f"주제 구독 완료 - 성공: {response.success_count}, 실패: {response.failure_count}")

            return {
                "success": response.success_count > 0,
                "message": f"주제 구독 완료 - 성공: {response.success_count}, 실패: {response.failure_count}",
                "success_count": response.success_count,
                "failure_count": response.failure_count
            }

        except Exception as e:
            logger.error(f"주제 구독 중 오류 발생: {e}")
            return {
                "success": False,
                "message": f"주제 구독 실패: {str(e)}"
            }

    async def unsubscribe_from_topic(self, tokens: List[str], topic: str) -> Dict[str, Any]:
        """FCM 토큰들을 특정 주제에서 구독 해제"""
        if not self.is_available():
            return {
                "success": False,
                "message": "Firebase 서비스를 사용할 수 없습니다"
            }

        try:
            response = messaging.unsubscribe_from_topic(tokens, topic)
            logger.info(f"주제 구독 해제 완료 - 성공: {response.success_count}, 실패: {response.failure_count}")

            return {
                "success": response.success_count > 0,
                "message": f"주제 구독 해제 완료 - 성공: {response.success_count}, 실패: {response.failure_count}",
                "success_count": response.success_count,
                "failure_count": response.failure_count
            }

        except Exception as e:
            logger.error(f"주제 구독 해제 중 오류 발생: {e}")
            return {
                "success": False,
                "message": f"주제 구독 해제 실패: {str(e)}"
            }


# 싱글톤 인스턴스
firebase_service = FirebaseService()