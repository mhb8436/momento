from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.models.user import User
from app.schemas.audio import TextProcessRequest, TextProcessResponse
from app.utils.dependencies import get_current_active_user
from app.services.credit_service import CreditService
from app.models.credit import APIUsageType

router = APIRouter()


@router.post("/process-text", response_model=TextProcessResponse)
async def process_transcript_text(
    request: TextProcessRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """클라이언트에서 처리된 음성 인식 텍스트를 받아서 레시피 생성 (크레딧 시스템 적용)"""
    
    try:
        print(f"🔍 텍스트 처리 시작: {len(request.transcript)} 문자")
        print(f"🔍 텍스트 내용 미리보기: {request.transcript[:100]}...")
        
        # 크레딧 시스템 체크
        credit_service = CreditService(db)
        
        # API 사용 가능 여부 체크
        can_use = await credit_service.can_use_api(str(current_user.id), APIUsageType.RECIPE_GENERATION)
        if not can_use:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail="크레딧이 부족합니다. 크레딧을 구매하거나 다음 달 무료 크레딧을 기다려주세요."
            )
        
        # GPT로 레시피 생성
        print(f"🔍 GPT 레시피 생성 시작")
        from app.services.gpt import organize_recipe_from_text
        from app.models.recipe import Recipe
        
        recipe_data = await organize_recipe_from_text(request.transcript)
        recipe_id = None
        
        if recipe_data:
            print(f"✅ GPT 레시피 생성 성공: {recipe_data['title']}")
            
            # 크레딧 차감
            deduction_result = await credit_service.deduct_credit(
                str(current_user.id),
                APIUsageType.RECIPE_GENERATION,
                {
                    "recipe_title": recipe_data.get("title", ""),
                    "transcript_length": len(request.transcript)
                }
            )
            
            if not deduction_result.success:
                raise HTTPException(
                    status_code=status.HTTP_402_PAYMENT_REQUIRED,
                    detail=deduction_result.message
                )
            
            print(f"💳 크레딧 차감 완료 - 무료티어: {deduction_result.used_free_tier}, 잔액: {deduction_result.remaining_balance}")
            
            # 레시피 데이터베이스에 저장
            recipe = Recipe(
                user_id=current_user.id,
                title=recipe_data.get("title", "정리된 레시피"),
                description=recipe_data.get("description", ""),
                ingredients=recipe_data.get("ingredients", []),
                steps=recipe_data.get("steps", []),
                tips=recipe_data.get("tips", ""),
                servings=recipe_data.get("servings", "2-3인분"),
                cooking_time=recipe_data.get("cooking_time", "30분"),
                difficulty=recipe_data.get("difficulty", "보통"),
                category=recipe_data.get("category", "한식")
            )
            
            db.add(recipe)
            await db.commit()
            await db.refresh(recipe)
            recipe_id = str(recipe.id)
            print(f"✅ 레시피 데이터베이스 저장 완료: {recipe_id}")
        else:
            print("❌ GPT 레시피 생성 실패")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to generate recipe from transcript"
            )
        
        return TextProcessResponse(
            transcript=request.transcript,
            processing_status="completed",
            recipe_id=recipe_id
        )
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ 텍스트 처리 중 예외 발생:")
        print(f"   오류 타입: {type(e).__name__}")
        print(f"   오류 메시지: {str(e)}")
        import traceback
        print(f"   스택 트레이스: {traceback.format_exc()}")
        
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Text processing failed: {str(e)}"
        )


