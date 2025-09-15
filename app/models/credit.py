from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Boolean, ForeignKey, Numeric, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base
import enum
import uuid


class PackageType(str, enum.Enum):
    """크레딧 패키지 타입 (크레딧 전용 모델)"""
    STARTER = "starter_10_credits"         # 10 크레딧 - ₩2,900
    FAMILY = "family_30_credits"           # 30 크레딧 - ₩7,900
    PREMIUM = "premium_100_credits"        # 100 크레딧 - ₩19,900
    MONTHLY_AUTO = "monthly_auto_recharge_50"  # 월간 자동충전 50개 - ₩9,900
    YEARLY_AUTO = "yearly_auto_recharge_100"   # 연간 자동충전 100개 - ₩99,900


class PaymentPlatform(str, enum.Enum):
    """결제 플랫폼"""
    IOS = "ios"
    ANDROID = "android"
    WEB = "web"


class PaymentStatus(str, enum.Enum):
    """결제 상태"""
    PENDING = "pending"
    VERIFIED = "verified"
    FAILED = "failed"
    REFUNDED = "refunded"


class APIUsageType(str, enum.Enum):
    """API 사용 타입"""
    RECIPE_GENERATION = "recipe_generation"
    RECIPE_IMPROVEMENT = "recipe_improvement"


class UserCredit(Base):
    """사용자 크레딧 관리"""
    __tablename__ = "user_credits"

    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    balance = Column(Integer, nullable=False, default=5)  # 현재 크레딧 잔액
    free_daily_used = Column(Integer, nullable=False, default=0)  # 오늘 무료 크레딧 사용량
    last_daily_reset = Column(DateTime(timezone=True), server_default=func.now())  # 마지막 일간 리셋 시간
    total_purchased = Column(Integer, nullable=False, default=0)  # 총 구매한 크레딧 수
    total_used = Column(Integer, nullable=False, default=0)  # 총 사용한 크레딧 수
    has_auto_recharge = Column(Boolean, default=False)  # 자동충전 설정 여부
    auto_recharge_expires_at = Column(DateTime(timezone=True), nullable=True)  # 자동충전 만료일
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="credit_info")


class PaymentHistory(Base):
    """결제 히스토리"""
    __tablename__ = "payment_history"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    package_type = Column(String(50), nullable=False)  # PackageType enum 값
    credits_amount = Column(Integer, nullable=False)  # 구매한 크레딧 수량
    price_paid = Column(Numeric(10, 2), nullable=False)  # 실제 결제 금액 (KRW)
    platform = Column(String(20), nullable=False)  # PaymentPlatform enum 값
    transaction_id = Column(String(255), nullable=False, unique=True)  # 플랫폼별 거래 ID
    receipt_data = Column(Text, nullable=True)  # 영수증 원본 데이터 (JSON string)
    status = Column(String(20), nullable=False, default=PaymentStatus.PENDING)
    verified_at = Column(DateTime(timezone=True), nullable=True)  # 검증 완료 시간
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    user = relationship("User")


class APIUsageLog(Base):
    """API 사용 로그"""
    __tablename__ = "api_usage_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    api_type = Column(String(50), nullable=False)  # APIUsageType enum 값
    credits_used = Column(Integer, nullable=False, default=1)  # 사용된 크레딧 수
    is_free_tier = Column(Boolean, default=False)  # 무료 티어 사용 여부
    extra_data = Column(Text, nullable=True)  # 추가 메타데이터 (JSON string)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    user = relationship("User")


class CreditPackage(Base):
    """크레딧 패키지 정보 (상품 카탈로그)"""
    __tablename__ = "credit_packages"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    package_type = Column(String(50), nullable=False, unique=True)  # PackageType enum 값
    name = Column(String(100), nullable=False)  # 패키지 이름
    credits_amount = Column(Integer, nullable=False)  # 크레딧 수량
    price_krw = Column(Numeric(10, 2), nullable=False)  # 가격 (KRW)
    discount_percentage = Column(Integer, default=0)  # 할인율 (%)
    is_active = Column(Boolean, default=True)  # 활성화 여부
    sort_order = Column(Integer, default=0)  # 정렬 순서
    description = Column(Text, nullable=True)  # 패키지 설명
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())