from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_, and_, cast, String
from typing import List, Optional
from app.database import get_db
from app.models.user import User
from app.models.recipe import Recipe
from app.schemas.recipe import RecipeCreate, RecipeResponse, RecipeUpdate
from app.utils.dependencies import get_current_active_user
from app.services.gpt import organize_recipe_from_text, improve_recipe_description

router = APIRouter()


@router.post("/", response_model=RecipeResponse)
async def create_recipe(
    recipe_data: RecipeCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """레시피 생성"""
    
    try:
        # 레시피 생성
        recipe = Recipe(
            user_id=current_user.id,
            title=recipe_data.title or "새 레시피",
            description=recipe_data.description,
            ingredients=recipe_data.ingredients,
            steps=recipe_data.steps,
            tips=recipe_data.tips,
            servings=recipe_data.servings,
            cooking_time=recipe_data.cooking_time,
            difficulty=recipe_data.difficulty,
            category=recipe_data.category
        )
        
        db.add(recipe)
        await db.commit()
        await db.refresh(recipe)
        
        return RecipeResponse(
            id=str(recipe.id),
            user_id=str(recipe.user_id),
            title=recipe.title,
            description=recipe.description,
            ingredients=recipe.ingredients,
            steps=recipe.steps,
            tips=recipe.tips,
            servings=recipe.servings,
            cooking_time=recipe.cooking_time,
            difficulty=recipe.difficulty,
            category=recipe.category,
            image_url=recipe.image_url,
            created_at=recipe.created_at,
            updated_at=recipe.updated_at
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create recipe: {str(e)}"
        )


@router.get("/", response_model=List[RecipeResponse])
async def get_user_recipes(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """사용자의 레시피 목록 조회"""
    
    result = await db.execute(
        select(Recipe)
        .where(Recipe.user_id == current_user.id)
        .order_by(Recipe.created_at.desc())
    )
    recipes = result.scalars().all()
    
    return [
        RecipeResponse(
            id=str(recipe.id),
            user_id=str(recipe.user_id),
            title=recipe.title,
            description=recipe.description,
            ingredients=recipe.ingredients,
            steps=recipe.steps,
            tips=recipe.tips,
            servings=recipe.servings,
            cooking_time=recipe.cooking_time,
            difficulty=recipe.difficulty,
            category=recipe.category,
            image_url=recipe.image_url,
            created_at=recipe.created_at,
            updated_at=recipe.updated_at
        )
        for recipe in recipes
    ]


@router.get("/{recipe_id}", response_model=RecipeResponse)
async def get_recipe(
    recipe_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """특정 레시피 상세 조회"""
    
    result = await db.execute(
        select(Recipe).where(
            Recipe.id == recipe_id,
            Recipe.user_id == current_user.id
        )
    )
    recipe = result.scalar_one_or_none()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recipe not found"
        )
    
    return RecipeResponse(
        id=str(recipe.id),
        user_id=str(recipe.user_id),
                title=recipe.title,
        description=recipe.description,
        ingredients=recipe.ingredients,
        steps=recipe.steps,
        tips=recipe.tips,
        servings=recipe.servings,
        cooking_time=recipe.cooking_time,
        difficulty=recipe.difficulty,
        category=recipe.category,
        created_at=recipe.created_at,
        updated_at=recipe.updated_at
    )


@router.put("/{recipe_id}", response_model=RecipeResponse)
async def update_recipe(
    recipe_id: str,
    recipe_update: RecipeUpdate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """레시피 수정"""
    
    result = await db.execute(
        select(Recipe).where(
            Recipe.id == recipe_id,
            Recipe.user_id == current_user.id
        )
    )
    recipe = result.scalar_one_or_none()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recipe not found"
        )
    
    # 업데이트할 필드들 적용
    update_data = recipe_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(recipe, field, value)
    
    await db.commit()
    await db.refresh(recipe)
    
    return RecipeResponse(
        id=str(recipe.id),
        user_id=str(recipe.user_id),
                title=recipe.title,
        description=recipe.description,
        ingredients=recipe.ingredients,
        steps=recipe.steps,
        tips=recipe.tips,
        servings=recipe.servings,
        cooking_time=recipe.cooking_time,
        difficulty=recipe.difficulty,
        category=recipe.category,
        created_at=recipe.created_at,
        updated_at=recipe.updated_at
    )


@router.delete("/{recipe_id}")
async def delete_recipe(
    recipe_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """레시피 삭제"""
    
    result = await db.execute(
        select(Recipe).where(
            Recipe.id == recipe_id,
            Recipe.user_id == current_user.id
        )
    )
    recipe = result.scalar_one_or_none()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recipe not found"
        )
    
    await db.delete(recipe)
    await db.commit()
    
    return {"message": "Recipe deleted successfully"}


@router.post("/{recipe_id}/improve-description")
async def improve_recipe_description_endpoint(
    recipe_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """레시피 설명을 AI로 개선"""
    
    result = await db.execute(
        select(Recipe).where(
            Recipe.id == recipe_id,
            Recipe.user_id == current_user.id
        )
    )
    recipe = result.scalar_one_or_none()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recipe not found"
        )
    
    try:
        recipe_data = {
            "title": recipe.title,
            "ingredients": recipe.ingredients or [],
            "tips": recipe.tips or ""
        }
        
        improved_description = await improve_recipe_description(recipe_data)
        
        if improved_description:
            recipe.description = improved_description
            await db.commit()
            
            return {"message": "Description improved", "description": improved_description}
        else:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to improve description"
            )
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to improve description: {str(e)}"
        )


