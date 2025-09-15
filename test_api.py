#!/usr/bin/env python3
"""
MOMENTO 크레딧 시스템 API 테스트 스크립트
서버가 실행 중일 때 바로 테스트 가능
"""

import requests
import json
import time
from typing import Optional

class MomentoCreditAPITester:
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.token: Optional[str] = None
        self.user_id: Optional[str] = None
        
    def test_server_health(self):
        """서버 상태 확인"""
        try:
            response = requests.get(f"{self.base_url}/health", timeout=5)
            print(f"✅ 서버 상태: {response.status_code}")
            return response.status_code == 200
        except Exception as e:
            print(f"❌ 서버 연결 실패: {e}")
            return False
    
    def login_test_user(self):
        """테스트 계정으로 로그인"""
        try:
            login_data = {
                "email": "test@momento.com",
                "password": "testpassword123"
            }
            
            response = requests.post(
                f"{self.base_url}/auth/login",
                data=login_data,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                self.token = data.get("access_token")
                print(f"✅ 로그인 성공: {self.token[:20]}...")
                return True
            else:
                print(f"❌ 로그인 실패: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ 로그인 오류: {e}")
            return False
    
    def get_headers(self):
        """인증 헤더 반환"""
        if not self.token:
            return {}
        return {"Authorization": f"Bearer {self.token}"}
    
    def test_credit_balance(self):
        """크레딧 잔액 조회 테스트"""
        try:
            response = requests.get(
                f"{self.base_url}/credits/balance",
                headers=self.get_headers(),
                timeout=10
            )
            
            if response.status_code == 200:
                balance = response.json()
                print(f"✅ 크레딧 잔액 조회 성공:")
                print(f"   💰 잔액: {balance.get('balance', 0)}개")
                print(f"   🎁 무료 사용량: {balance.get('free_monthly_used', 0)}개")
                print(f"   📅 구독 상태: {balance.get('subscription_active_until', 'None')}")
                return True
            else:
                print(f"❌ 크레딧 잔액 조회 실패: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ 크레딧 잔액 조회 오류: {e}")
            return False
    
    def test_credit_packages(self):
        """크레딧 패키지 목록 조회 테스트"""
        try:
            response = requests.get(
                f"{self.base_url}/credits/packages",
                headers=self.get_headers(),
                timeout=10
            )
            
            if response.status_code == 200:
                packages = response.json()
                print(f"✅ 패키지 목록 조회 성공 ({len(packages)}개):")
                for package in packages:
                    print(f"   📦 {package['name']}: {package['credits_amount']}개 - ₩{package['price_krw']:,}")
                return True
            else:
                print(f"❌ 패키지 목록 조회 실패: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ 패키지 목록 조회 오류: {e}")
            return False
    
    def test_payment_history(self):
        """결제 히스토리 조회 테스트"""
        try:
            response = requests.get(
                f"{self.base_url}/credits/history",
                headers=self.get_headers(),
                timeout=10
            )
            
            if response.status_code == 200:
                history = response.json()
                print(f"✅ 결제 히스토리 조회 성공 ({len(history)}개):")
                for payment in history[:3]:  # 최근 3개만 표시
                    print(f"   💳 {payment['package_type']}: ₩{payment['amount_krw']} ({payment['created_at'][:10]})")
                return True
            else:
                print(f"❌ 결제 히스토리 조회 실패: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ 결제 히스토리 조회 오류: {e}")
            return False
    
    def test_usage_stats(self):
        """사용량 통계 조회 테스트"""
        try:
            response = requests.get(
                f"{self.base_url}/credits/usage-stats",
                headers=self.get_headers(),
                timeout=10
            )
            
            if response.status_code == 200:
                stats = response.json()
                print(f"✅ 사용량 통계 조회 성공:")
                print(f"   📊 총 사용량: {stats.get('total_used', 0)}개")
                print(f"   📅 이번 달: {stats.get('monthly_used', 0)}개")
                print(f"   🔥 가장 많이 사용한 기능: {stats.get('most_used_api', 'N/A')}")
                return True
            else:
                print(f"❌ 사용량 통계 조회 실패: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ 사용량 통계 조회 오류: {e}")
            return False
    
    def test_purchase_verification(self):
        """구매 검증 테스트 (Mock 데이터)"""
        try:
            # 테스트용 Mock 영수증 데이터
            verification_data = {
                "package_type": "starter_10_credits",
                "transaction_id": f"test_transaction_{int(time.time())}",
                "receipt_data": "mock_receipt_data_for_testing",
                "platform": "ios"
            }
            
            response = requests.post(
                f"{self.base_url}/credits/purchase/verify",
                headers=self.get_headers(),
                json=verification_data,
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                print(f"✅ 구매 검증 테스트 성공:")
                print(f"   🔐 검증 결과: {result.get('success', False)}")
                print(f"   💬 메시지: {result.get('message', 'N/A')}")
                return True
            else:
                print(f"❌ 구매 검증 테스트 실패: {response.status_code}")
                print(f"   응답: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ 구매 검증 테스트 오류: {e}")
            return False
    
    def run_all_tests(self):
        """모든 테스트 실행"""
        print("🧪 MOMENTO 크레딧 시스템 API 테스트 시작\n")
        
        tests = [
            ("서버 상태 확인", self.test_server_health),
            ("테스트 계정 로그인", self.login_test_user),
            ("크레딧 잔액 조회", self.test_credit_balance),
            ("크레딧 패키지 목록", self.test_credit_packages),
            ("결제 히스토리", self.test_payment_history),
            ("사용량 통계", self.test_usage_stats),
            ("구매 검증 (Mock)", self.test_purchase_verification),
        ]
        
        passed = 0
        total = len(tests)
        
        for test_name, test_func in tests:
            print(f"\n📋 {test_name} 테스트 중...")
            if test_func():
                passed += 1
            time.sleep(0.5)  # API 호출 간격
        
        print(f"\n📊 테스트 결과: {passed}/{total} 통과")
        if passed == total:
            print("🎉 모든 테스트가 성공했습니다!")
        else:
            print("⚠️  일부 테스트가 실패했습니다. 서버 상태를 확인해주세요.")
        
        return passed == total

def main():
    """메인 실행 함수"""
    print("MOMENTO 크레딧 시스템 API 테스터")
    print("=" * 50)
    
    # 서버 URL 확인
    server_url = input("서버 URL (기본값: http://localhost:8000): ").strip()
    if not server_url:
        server_url = "http://localhost:8000"
    
    # 테스터 인스턴스 생성 및 실행
    tester = MomentoCreditAPITester(server_url)
    success = tester.run_all_tests()
    
    if success:
        print("\n✅ API 테스트 완료! 인앱 결제 시스템이 정상 작동합니다.")
    else:
        print("\n❌ API 테스트에서 문제가 발견되었습니다.")
        print("다음을 확인해주세요:")
        print("1. 서버가 실행 중인지 확인")
        print("2. 데이터베이스 연결 상태 확인")
        print("3. 테스트 계정이 생성되었는지 확인")

if __name__ == "__main__":
    main()