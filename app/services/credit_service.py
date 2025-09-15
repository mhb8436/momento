from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, func
from sqlalchemy.orm import selectinload
from typing import Optional, Dict, Any
import json
from decimal import Decimal

from app.models.user import User
from app.models.credit import (
    UserCredit, PaymentHistory, APIUsageLog, CreditPackage,
    PackageType, PaymentPlatform, PaymentStatus, APIUsageType
)
from app.schemas.credit import (
    CreditBalanceResponse, CreditDeductionResult, UsageStatsResponse,
    APIUsageLogResponse, CreditConfig
)


class CreditService:
    """크레딧 시스템 핵심 서비스"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_or_create_user_credit(self, user_id: str) -> UserCredit:
        """사용자 크레딧 정보 조회 또는 생성"""
        result = await self.db.execute(
            select(UserCredit).where(UserCredit.user_id == user_id)
        )
        user_credit = result.scalar_one_or_none()
        
        if not user_credit:
            # 신규 사용자 크레딧 정보 생성
            user_credit = UserCredit(
                user_id=user_id,
                balance=CreditConfig.INITIAL_FREE_CREDITS,
                free_daily_used=0,
                total_purchased=0,
                total_used=0
            )
            self.db.add(user_credit)
            await self.db.commit()
            await self.db.refresh(user_credit)
        
        return user_credit
    
    async def get_credit_balance(self, user_id: str) -> CreditBalanceResponse:
        """사용자 크레딧 잔액 조회"""
        user_credit = await self.get_or_create_user_credit(user_id)
        
        # 월간 무료 크레딧 리셋 체크
        await self._check_daily_reset(user_credit)
        
        return CreditBalanceResponse(
            balance=user_credit.balance,
            free_daily_used=user_credit.free_daily_used,
            free_daily_limit=CreditConfig.DAILY_FREE_CREDITS,
            has_auto_recharge=user_credit.has_auto_recharge,
            auto_recharge_expires_at=user_credit.auto_recharge_expires_at,
            total_purchased=user_credit.total_purchased,
            total_used=user_credit.total_used,
            # 프론트엔드에서 하드코딩 제거를 위한 설정 정보 추가
            daily_free_credits=CreditConfig.DAILY_FREE_CREDITS,
            initial_free_credits=CreditConfig.INITIAL_FREE_CREDITS,
            recipe_generation_cost=CreditConfig.RECIPE_GENERATION_COST,
            recipe_improvement_cost=CreditConfig.RECIPE_IMPROVEMENT_COST
        )
    
    async def can_use_api(self, user_id: str, api_type: APIUsageType) -> bool:
        """API 사용 가능 여부 체크"""
        user_credit = await self.get_or_create_user_credit(user_id)
        await self._check_daily_reset(user_credit)
        
        # 무료 일간 크레딧 사용 가능 여부 체크 (구독 무제한 모델 제거)
        if user_credit.free_daily_used < CreditConfig.DAILY_FREE_CREDITS:
            return True
        
        # 구매한 크레딧 사용 가능 여부 체크
        return user_credit.balance > 0
    
    async def deduct_credit(self, user_id: str, api_type: APIUsageType, metadata: Optional[Dict] = None) -> CreditDeductionResult:
        """크레딧 차감"""
        user_credit = await self.get_or_create_user_credit(user_id)
        await self._check_daily_reset(user_credit)
        
        credits_to_deduct = self._get_api_cost(api_type)
        used_free_tier = False
        
        # 무료 일간 크레딧 먼저 사용 (구독 무제한 모델 제거)
        if user_credit.free_daily_used < CreditConfig.DAILY_FREE_CREDITS:
            user_credit.free_daily_used += credits_to_deduct
            used_free_tier = True
        # 구매한 크레딧 사용
        elif user_credit.balance >= credits_to_deduct:
            user_credit.balance -= credits_to_deduct
        else:
            return CreditDeductionResult(
                success=False,
                remaining_balance=user_credit.balance,
                used_free_tier=False,
                message="크레딧이 부족합니다. 크레딧을 구매해주세요."
            )
        
        # 총 사용량 업데이트
        user_credit.total_used += credits_to_deduct
        
        # 사용 로그 기록
        usage_log = APIUsageLog(
            user_id=user_id,
            api_type=api_type.value,
            credits_used=credits_to_deduct,
            is_free_tier=used_free_tier,
            extra_data=json.dumps(metadata) if metadata else None
        )
        self.db.add(usage_log)
        
        await self.db.commit()
        
        return CreditDeductionResult(
            success=True,
            remaining_balance=user_credit.balance,
            used_free_tier=used_free_tier,
            message="API 사용이 성공적으로 기록되었습니다."
        )
    
    async def add_credits(self, user_id: str, credits_amount: int, source: str = "purchase") -> bool:
        """크레딧 추가"""
        user_credit = await self.get_or_create_user_credit(user_id)
        
        user_credit.balance += credits_amount
        if source == "purchase":
            user_credit.total_purchased += credits_amount
        
        await self.db.commit()
        return True
    
    async def get_usage_stats(self, user_id: str) -> UsageStatsResponse:
        """사용 통계 조회"""
        # 이번 달 사용량
        current_month_start = datetime.now().replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        
        current_month_result = await self.db.execute(
            select(func.coalesce(func.sum(APIUsageLog.credits_used), 0))
            .where(
                and_(
                    APIUsageLog.user_id == user_id,
                    APIUsageLog.created_at >= current_month_start
                )
            )
        )
        current_month_usage = current_month_result.scalar() or 0
        
        # 이번 달 무료 사용량
        current_month_free_result = await self.db.execute(
            select(func.coalesce(func.sum(APIUsageLog.credits_used), 0))
            .where(
                and_(
                    APIUsageLog.user_id == user_id,
                    APIUsageLog.created_at >= current_month_start,
                    APIUsageLog.is_free_tier == True
                )
            )
        )
        current_month_free = current_month_free_result.scalar() or 0
        
        # 최근 30일 사용량
        thirty_days_ago = datetime.now() - timedelta(days=30)
        last_30_days_result = await self.db.execute(
            select(func.coalesce(func.sum(APIUsageLog.credits_used), 0))
            .where(
                and_(
                    APIUsageLog.user_id == user_id,
                    APIUsageLog.created_at >= thirty_days_ago
                )
            )
        )
        last_30_days_usage = last_30_days_result.scalar() or 0
        
        # 총 레시피 생성 수
        total_recipes_result = await self.db.execute(
            select(func.count(APIUsageLog.id))
            .where(
                and_(
                    APIUsageLog.user_id == user_id,
                    APIUsageLog.api_type == APIUsageType.RECIPE_GENERATION.value
                )
            )
        )
        total_recipes_created = total_recipes_result.scalar() or 0
        
        # 최근 사용 내역 (최근 10개)
        recent_usage_result = await self.db.execute(
            select(APIUsageLog)
            .where(APIUsageLog.user_id == user_id)
            .order_by(APIUsageLog.created_at.desc())
            .limit(10)
        )
        recent_logs = recent_usage_result.scalars().all()
        
        recent_usage = [
            APIUsageLogResponse(
                id=str(log.id),
                api_type=log.api_type,
                credits_used=log.credits_used,
                is_free_tier=log.is_free_tier,
                created_at=log.created_at
            )
            for log in recent_logs
        ]
        
        return UsageStatsResponse(
            current_month_usage=current_month_usage,
            current_month_free=current_month_free,
            last_30_days_usage=last_30_days_usage,
            total_recipes_created=total_recipes_created,
            recent_usage=recent_usage
        )
    
    async def _check_daily_reset(self, user_credit: UserCredit) -> None:
        """일간 무료 크레딧 리셋 체크"""
        now = datetime.now()
        last_reset = user_credit.last_daily_reset
        
        # 날짜가 바뀌었으면 리셋
        if last_reset.date() != now.date():
            user_credit.free_daily_used = 0
            user_credit.last_daily_reset = now
            await self.db.commit()
    
    def _is_auto_recharge_active(self, user_credit: UserCredit) -> bool:
        """자동충전 활성 상태 체크"""
        if not user_credit.has_auto_recharge:
            return False
        
        if user_credit.auto_recharge_expires_at is None:
            return False
        
        return user_credit.auto_recharge_expires_at > datetime.now()
    
    def _get_api_cost(self, api_type: APIUsageType) -> int:
        """API 타입별 비용 반환"""
        costs = {
            APIUsageType.RECIPE_GENERATION: CreditConfig.RECIPE_GENERATION_COST,
            APIUsageType.RECIPE_IMPROVEMENT: CreditConfig.RECIPE_IMPROVEMENT_COST
        }
        return costs.get(api_type, 1)


class PaymentService:
    """결제 관련 서비스"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
        self.credit_service = CreditService(db)
    
    async def verify_purchase(self, user_id: str, transaction_id: str, platform: PaymentPlatform, 
                            package_type: str, receipt_data: str) -> Dict[str, Any]:
        """결제 검증"""
        try:
            # 중복 거래 체크
            existing_payment = await self.db.execute(
                select(PaymentHistory).where(PaymentHistory.transaction_id == transaction_id)
            )
            if existing_payment.scalar_one_or_none():
                return {
                    "success": False,
                    "message": "이미 처리된 거래입니다."
                }
            
            # 패키지 정보 조회
            package_info = CreditConfig.PACKAGES.get(package_type)
            if not package_info:
                return {
                    "success": False,
                    "message": "잘못된 패키지 타입입니다."
                }
            
            # TODO: 실제 플랫폼별 영수증 검증 로직 구현
            # 현재는 개발용으로 항상 성공으로 처리
            is_valid = await self._verify_receipt(platform, receipt_data, package_type)
            
            if not is_valid:
                return {
                    "success": False,
                    "message": "영수증 검증에 실패했습니다."
                }
            
            # 결제 히스토리 저장
            payment = PaymentHistory(
                user_id=user_id,
                package_type=package_type,
                credits_amount=package_info["credits"],
                price_paid=Decimal(str(package_info["price"])),
                platform=platform.value,
                transaction_id=transaction_id,
                receipt_data=receipt_data,
                status=PaymentStatus.VERIFIED.value,
                verified_at=datetime.now()
            )
            self.db.add(payment)
            
            # 크레딧 추가
            await self.credit_service.add_credits(user_id, package_info["credits"])
            
            await self.db.commit()
            
            # 새로운 잔액 조회
            balance_info = await self.credit_service.get_credit_balance(user_id)
            
            return {
                "success": True,
                "credits_added": package_info["credits"],
                "new_balance": balance_info.balance,
                "message": f"{package_info['credits']}개의 크레딧이 추가되었습니다."
            }
            
        except Exception as e:
            await self.db.rollback()
            return {
                "success": False,
                "message": f"결제 처리 중 오류가 발생했습니다: {str(e)}"
            }
    
    async def _verify_receipt(self, platform: PaymentPlatform, receipt_data: str, package_type: str) -> bool:
        """플랫폼별 영수증 검증"""
        # TODO: 실제 영수증 검증 로직 구현
        # iOS: App Store Connect API
        # Android: Google Play Console API
        
        # 개발용으로 항상 True 반환
        return True