from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_, desc
from sqlalchemy.orm import selectinload
from typing import List, Optional
from uuid import UUID
from datetime import datetime, timedelta

from app.database import get_db
from app.models.recipe import Recipe, RecipeReaction, RecipeBookmark, RecipeVisibility, ReactionType
from app.models.user import User
from app.schemas.recipe import RecipeResponse
from app.utils.dependencies import get_current_user

router = APIRouter(prefix="/community", tags=["community"])


@router.get("/recipes/popular", response_model=List[RecipeResponse])
async def get_popular_recipes(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=50),
    period: str = Query("week", regex="^(week|month|all)$"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    인기 레시피를 조회합니다 (리액션 수 기준).
    """
    # Base query with joins
    query = select(Recipe).options(
        selectinload(Recipe.user),
        selectinload(Recipe.reactions),
        selectinload(Recipe.bookmarks)
    ).where(
        or_(
            Recipe.visibility == RecipeVisibility.public,
            Recipe.visibility == RecipeVisibility.neighborhood,
            Recipe.visibility == RecipeVisibility.family
        )
    )
    
    # Apply period filter if not 'all'
    if period != "all":
        days_back = 7 if period == "week" else 30
        cutoff_date = datetime.utcnow() - timedelta(days=days_back)
        query = query.where(Recipe.created_at >= cutoff_date)
    
    # Order by reaction count (we'll do this with subquery)
    reaction_count_subquery = select(
        RecipeReaction.recipe_id,
        func.count(RecipeReaction.id).label('reaction_count')
    ).group_by(RecipeReaction.recipe_id).subquery()
    
    query = query.outerjoin(
        reaction_count_subquery, 
        Recipe.id == reaction_count_subquery.c.recipe_id
    ).order_by(
        desc(reaction_count_subquery.c.reaction_count),
        Recipe.created_at.desc()
    )
    
    # Apply pagination
    offset = (page - 1) * limit
    query = query.offset(offset).limit(limit)
    
    result = await db.execute(query)
    recipes = result.scalars().all()
    
    # Convert to response format with community data
    response_recipes = []
    for recipe in recipes:
        # Calculate reaction counts
        reaction_counts = {}
        total_reactions = 0
        for reaction in recipe.reactions:
            reaction_type = reaction.reaction_type.value
            reaction_counts[reaction_type] = reaction_counts.get(reaction_type, 0) + 1
            total_reactions += 1
        
        # Check if current user bookmarked this recipe
        is_bookmarked = any(bookmark.user_id == current_user.id for bookmark in recipe.bookmarks)
        
        recipe_response = RecipeResponse(
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
            visibility=recipe.visibility,
            created_at=recipe.created_at,
            updated_at=recipe.updated_at,
            author_name=recipe.user.full_name,
            reaction_counts=reaction_counts,
            total_reactions=total_reactions,
            is_bookmarked=is_bookmarked
        )
        response_recipes.append(recipe_response)
    
    return response_recipes


@router.get("/users/{user_id}/recipes", response_model=List[RecipeResponse])
async def get_user_public_recipes(
    user_id: UUID,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    특정 사용자의 공개 레시피 목록을 조회합니다.
    """
    # Check if user exists
    user_query = select(User).where(User.id == user_id)
    user_result = await db.execute(user_query)
    target_user = user_result.scalar_one_or_none()
    
    if not target_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Base query with joins
    query = select(Recipe).options(
        selectinload(Recipe.user),
        selectinload(Recipe.reactions),
        selectinload(Recipe.bookmarks)
    ).where(
        and_(
            Recipe.user_id == user_id,
            or_(
                Recipe.visibility == RecipeVisibility.public,
                Recipe.visibility == RecipeVisibility.neighborhood,
                Recipe.visibility == RecipeVisibility.family
            )
        )
    ).order_by(Recipe.created_at.desc())
    
    # Apply pagination
    offset = (page - 1) * limit
    query = query.offset(offset).limit(limit)
    
    result = await db.execute(query)
    recipes = result.scalars().all()
    
    # Convert to response format with community data
    response_recipes = []
    for recipe in recipes:
        # Calculate reaction counts
        reaction_counts = {}
        total_reactions = 0
        for reaction in recipe.reactions:
            reaction_type = reaction.reaction_type.value
            reaction_counts[reaction_type] = reaction_counts.get(reaction_type, 0) + 1
            total_reactions += 1
        
        # Check if current user bookmarked this recipe
        is_bookmarked = any(bookmark.user_id == current_user.id for bookmark in recipe.bookmarks)
        
        recipe_response = RecipeResponse(
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
            visibility=recipe.visibility,
            created_at=recipe.created_at,
            updated_at=recipe.updated_at,
            author_name=recipe.user.full_name,
            reaction_counts=reaction_counts,
            total_reactions=total_reactions,
            is_bookmarked=is_bookmarked
        )
        response_recipes.append(recipe_response)
    
    return response_recipes