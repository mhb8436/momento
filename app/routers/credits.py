from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.database import get_db
from app.models.user import User
from app.models.credit import CreditPackage, PaymentHistory, PaymentPlatform
from app.schemas.credit import (
    CreditBalanceResponse, CreditPackageResponse, PurchaseRequest,
    PurchaseVerificationResponse, PaymentHistoryResponse, UsageStatsResponse,
    CreditConfig
)
from app.services.credit_service import CreditService, PaymentService
from app.utils.dependencies import get_current_active_user

router = APIRouter()


@router.get("/balance", response_model=CreditBalanceResponse)
async def get_credit_balance(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """현재 사용자의 크레딧 잔액 조회"""
    credit_service = CreditService(db)
    return await credit_service.get_credit_balance(str(current_user.id))


@router.get("/packages", response_model=List[CreditPackageResponse])
async def get_credit_packages(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """구매 가능한 크레딧 패키지 목록 조회"""
    packages = []
    
    for package_type, info in CreditConfig.PACKAGES.items():
        # 추천 패키지 설정 (패밀리 패키지)
        is_recommended = package_type == "family_30_credits"
        
        packages.append(CreditPackageResponse(
            package_type=package_type,
            name=info["name"],
            credits_amount=info["credits"],
            price_krw=info["price"],
            discount_percentage=info["discount"],
            description=_get_package_description(package_type, info),
            is_recommended=is_recommended
        ))
    
    # 가격순으로 정렬
    packages.sort(key=lambda x: x.price_krw)
    return packages


@router.post("/purchase/verify", response_model=PurchaseVerificationResponse)
async def verify_purchase(
    purchase_request: PurchaseRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """인앱 결제 검증 및 크레딧 지급"""
    try:
        # 플랫폼 검증
        if purchase_request.platform not in ["ios", "android"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="지원하지 않는 플랫폼입니다."
            )
        
        # 패키지 타입 검증
        if purchase_request.package_type not in CreditConfig.PACKAGES:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="잘못된 패키지 타입입니다."
            )
        
        payment_service = PaymentService(db)
        platform = PaymentPlatform.IOS if purchase_request.platform == "ios" else PaymentPlatform.ANDROID
        
        result = await payment_service.verify_purchase(
            user_id=str(current_user.id),
            transaction_id=purchase_request.transaction_id,
            platform=platform,
            package_type=purchase_request.package_type,
            receipt_data=purchase_request.receipt_data
        )
        
        return PurchaseVerificationResponse(
            success=result["success"],
            credits_added=result.get("credits_added", 0),
            new_balance=result.get("new_balance", 0),
            message=result["message"]
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"결제 검증 중 오류가 발생했습니다: {str(e)}"
        )


@router.get("/history", response_model=List[PaymentHistoryResponse])
async def get_payment_history(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """결제 히스토리 조회"""
    result = await db.execute(
        select(PaymentHistory)
        .where(PaymentHistory.user_id == current_user.id)
        .order_by(PaymentHistory.created_at.desc())
        .limit(50)  # 최근 50개만
    )
    payments = result.scalars().all()
    
    return [
        PaymentHistoryResponse(
            id=str(payment.id),
            package_type=payment.package_type,
            credits_amount=payment.credits_amount,
            price_paid=payment.price_paid,
            platform=payment.platform,
            status=payment.status,
            created_at=payment.created_at,
            verified_at=payment.verified_at
        )
        for payment in payments
    ]


@router.get("/usage/stats", response_model=UsageStatsResponse)
async def get_usage_statistics(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """사용 통계 조회"""
    credit_service = CreditService(db)
    return await credit_service.get_usage_stats(str(current_user.id))


@router.post("/test-deduct")
async def test_credit_deduction(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """크레딧 차감 테스트 (개발용)"""
    from app.models.credit import APIUsageType
    
    credit_service = CreditService(db)
    
    # API 사용 가능 여부 체크
    can_use = await credit_service.can_use_api(str(current_user.id), APIUsageType.RECIPE_GENERATION)
    if not can_use:
        raise HTTPException(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail="크레딧이 부족합니다. 크레딧을 구매해주세요."
        )
    
    # 크레딧 차감
    result = await credit_service.deduct_credit(
        str(current_user.id), 
        APIUsageType.RECIPE_GENERATION,
        {"test": True}
    )
    
    return {
        "success": result.success,
        "remaining_balance": result.remaining_balance,
        "used_free_tier": result.used_free_tier,
        "message": result.message
    }


def _get_package_description(package_type: str, info: dict) -> str:
    """패키지 설명 생성"""
    descriptions = {
        "starter_10_credits": "시작하기에 딱 좋은 패키지입니다",
        "family_30_credits": "⭐ 가족과 함께! 가장 인기 있는 패키지",
        "premium_100_credits": "많은 레시피를 만들 수 있는 프리미엄 패키지",
        "monthly_subscription": "매월 자동으로 크레딧을 받아보세요",
        "yearly_subscription": "1년 구독으로 최대 33% 절약하세요"
    }
    
    base_desc = descriptions.get(package_type, "")
    
    if info["discount"] > 0:
        base_desc += f" • {info['discount']}% 할인"
    
    return base_desc