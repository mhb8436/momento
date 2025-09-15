from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import datetime
from decimal import Decimal


class CreditBalanceResponse(BaseModel):
    """크레딧 잔액 응답"""
    balance: int = Field(..., description="현재 크레딧 잔액")
    free_daily_used: int = Field(..., description="오늘 무료 크레딧 사용량")
    free_daily_limit: int = Field(..., description="일간 무료 크레딧 한도")
    has_auto_recharge: bool = Field(..., description="자동충전 설정 여부")
    auto_recharge_expires_at: Optional[datetime] = Field(None, description="자동충전 만료일")
    total_purchased: int = Field(..., description="총 구매한 크레딧")
    total_used: int = Field(..., description="총 사용한 크레딧")
    
    # 프론트엔드에서 하드코딩 제거를 위한 설정 정보 추가
    daily_free_credits: int = Field(..., description="하루 제공되는 무료 크레딧 개수")
    initial_free_credits: int = Field(..., description="신규 가입 시 제공되는 크레딧 개수")
    recipe_generation_cost: int = Field(..., description="레시피 생성 비용")
    recipe_improvement_cost: int = Field(..., description="레시피 개선 비용")


class CreditPackageResponse(BaseModel):
    """크레딧 패키지 정보"""
    package_type: str = Field(..., description="패키지 타입")
    name: str = Field(..., description="패키지 이름")
    credits_amount: int = Field(..., description="크레딧 수량")
    price_krw: Decimal = Field(..., description="가격 (KRW)")
    discount_percentage: int = Field(default=0, description="할인율 (%)")
    description: Optional[str] = Field(None, description="패키지 설명")
    is_recommended: bool = Field(default=False, description="추천 여부")


class PurchaseRequest(BaseModel):
    """결제 요청"""
    package_type: str = Field(..., description="구매할 패키지 타입")
    platform: str = Field(..., description="결제 플랫폼 (ios/android)")
    transaction_id: str = Field(..., description="플랫폼별 거래 ID")
    receipt_data: str = Field(..., description="영수증 데이터")


class PurchaseVerificationResponse(BaseModel):
    """결제 검증 응답"""
    success: bool = Field(..., description="검증 성공 여부")
    credits_added: int = Field(default=0, description="추가된 크레딧 수")
    new_balance: int = Field(..., description="새로운 크레딧 잔액")
    message: str = Field(..., description="결과 메시지")


class PaymentHistoryResponse(BaseModel):
    """결제 히스토리 응답"""
    id: str = Field(..., description="결제 ID")
    package_type: str = Field(..., description="패키지 타입")
    credits_amount: int = Field(..., description="구매한 크레딧 수")
    price_paid: Decimal = Field(..., description="결제 금액")
    platform: str = Field(..., description="결제 플랫폼")
    status: str = Field(..., description="결제 상태")
    created_at: datetime = Field(..., description="결제 일시")
    verified_at: Optional[datetime] = Field(None, description="검증 완료 일시")


class APIUsageLogResponse(BaseModel):
    """API 사용 로그 응답"""
    id: str = Field(..., description="로그 ID")
    api_type: str = Field(..., description="API 타입")
    credits_used: int = Field(..., description="사용된 크레딧 수")
    is_free_tier: bool = Field(..., description="무료 티어 사용 여부")
    created_at: datetime = Field(..., description="사용 일시")


class UsageStatsResponse(BaseModel):
    """사용 통계 응답"""
    current_month_usage: int = Field(..., description="이번 달 사용량")
    current_month_free: int = Field(..., description="이번 달 무료 사용량")
    last_30_days_usage: int = Field(..., description="최근 30일 사용량")
    total_recipes_created: int = Field(..., description="총 생성한 레시피 수")
    recent_usage: List[APIUsageLogResponse] = Field(..., description="최근 사용 내역")


class CreditDeductionResult(BaseModel):
    """크레딧 차감 결과"""
    success: bool = Field(..., description="차감 성공 여부")
    remaining_balance: int = Field(..., description="남은 크레딧 잔액")
    used_free_tier: bool = Field(..., description="무료 티어 사용 여부")
    message: str = Field(..., description="결과 메시지")


class SubscriptionInfo(BaseModel):
    """구독 정보"""
    is_active: bool = Field(..., description="구독 활성 상태")
    plan_type: Optional[str] = Field(None, description="구독 플랜 타입")
    expires_at: Optional[datetime] = Field(None, description="구독 만료일")
    monthly_credits: int = Field(default=0, description="월간 제공 크레딧")
    days_remaining: Optional[int] = Field(None, description="남은 구독 일수")


class CreditTransferRequest(BaseModel):
    """크레딧 전송 요청 (가족 공유 기능용)"""
    recipient_email: str = Field(..., description="받는 사람 이메일")
    credits_amount: int = Field(..., ge=1, le=50, description="전송할 크레딧 수 (1-50)")
    message: Optional[str] = Field(None, max_length=200, description="전송 메시지")


class PromotionCodeRequest(BaseModel):
    """프로모션 코드 사용 요청"""
    promo_code: str = Field(..., description="프로모션 코드")


class PromotionCodeResponse(BaseModel):
    """프로모션 코드 응답"""
    success: bool = Field(..., description="적용 성공 여부")
    credits_added: int = Field(default=0, description="추가된 크레딧 수")
    message: str = Field(..., description="결과 메시지")


# 설정값들
class CreditConfig:
    """크레딧 시스템 설정"""
    INITIAL_FREE_CREDITS = 5  # 신규 가입 크레딧
    DAILY_FREE_CREDITS = 2  # 일간 무료 크레딧
    RECIPE_GENERATION_COST = 1  # 레시피 생성 비용
    RECIPE_IMPROVEMENT_COST = 1  # 레시피 개선 비용
    
    # 패키지 정보 (크레딧 전용 모델)
    PACKAGES = {
        "starter_10_credits": {
            "name": "스타터 패키지",
            "credits": 10,
            "price": 2900,
            "discount": 0,
            "type": "one_time"  # 일회성 구매
        },
        "family_30_credits": {
            "name": "패밀리 패키지", 
            "credits": 30,
            "price": 7900,
            "discount": 17,
            "type": "one_time"
        },
        "premium_100_credits": {
            "name": "프리미엄 패키지",
            "credits": 100,
            "price": 19900,
            "discount": 32,
            "type": "one_time"
        },
        "monthly_auto_recharge_50": {
            "name": "월간 자동충전 50개",
            "credits": 50,
            "price": 9900,
            "discount": 20,
            "type": "monthly_auto"  # 월간 자동충전
        },
        "yearly_auto_recharge_100": {
            "name": "연간 자동충전 100개",
            "credits": 100,  # 월간 100개
            "price": 99900,  # 연간
            "discount": 30,
            "type": "yearly_auto"  # 연간 자동충전
        }
    }