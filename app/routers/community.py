from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_
from sqlalchemy.orm import selectinload
from typing import List, Optional, Dict
from uuid import UUID

from app.database import get_db
from app.models.recipe import Recipe, RecipeReaction, RecipeBookmark, RecipeVisibility, ReactionType
from app.models.user import User
from app.schemas.recipe import (
    RecipeResponse, RecipeVisibilityUpdate, RecipeReactionCreate, 
    RecipeReactionResponse, RecipeBookmarkResponse
)
from app.utils.dependencies import get_current_user

router = APIRouter(prefix="/community", tags=["community"])


@router.get("/recipes", response_model=List[RecipeResponse])
async def get_public_recipes(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=50),
    category: Optional[str] = None,
    difficulty: Optional[str] = None,
    visibility: Optional[RecipeVisibility] = None,
    search: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    공개 레시피 목록을 조회합니다.
    """
    # Base query with joins
    query = select(Recipe).options(
        selectinload(Recipe.user),
        selectinload(Recipe.reactions),
        selectinload(Recipe.bookmarks)
    )
    
    # Visibility filter - only show public recipes or family recipes
    if visibility:
        query = query.where(Recipe.visibility == visibility)
    else:
        query = query.where(or_(
            Recipe.visibility == RecipeVisibility.public,
            Recipe.visibility == RecipeVisibility.neighborhood,
            Recipe.visibility == RecipeVisibility.family
        ))
    
    # Additional filters
    if category:
        query = query.where(Recipe.category == category)
    if difficulty:
        query = query.where(Recipe.difficulty == difficulty)
    if search:
        query = query.where(or_(
            Recipe.title.ilike(f"%{search}%"),
            Recipe.description.ilike(f"%{search}%")
        ))
    
    # Order by created_at desc and apply pagination
    query = query.order_by(Recipe.created_at.desc())
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


@router.get("/recipes/search", response_model=List[RecipeResponse])
async def search_recipes(
    q: str = Query(..., min_length=1),
    category: Optional[str] = None,
    difficulty: Optional[str] = None,
    visibility: Optional[RecipeVisibility] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    레시피를 검색합니다.
    """
    # Base query with search
    query = select(Recipe).options(
        selectinload(Recipe.user),
        selectinload(Recipe.reactions),
        selectinload(Recipe.bookmarks)
    ).where(
        and_(
            or_(
                Recipe.visibility == RecipeVisibility.public,
                Recipe.visibility == RecipeVisibility.neighborhood,
                Recipe.visibility == RecipeVisibility.family
            ),
            or_(
                Recipe.title.ilike(f"%{q}%"),
                Recipe.description.ilike(f"%{q}%")
            )
        )
    )
    
    # Additional filters
    if category:
        query = query.where(Recipe.category == category)
    if difficulty:
        query = query.where(Recipe.difficulty == difficulty)
    if visibility:
        query = query.where(Recipe.visibility == visibility)
    
    # Order by relevance (title matches first, then description)
    query = query.order_by(
        func.case(
            (Recipe.title.ilike(f"%{q}%"), 1),
            else_=2
        ).asc(),
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


@router.put("/recipes/{recipe_id}/visibility", response_model=RecipeResponse)
async def update_recipe_visibility(
    recipe_id: UUID,
    visibility_update: RecipeVisibilityUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    레시피의 공개 범위를 변경합니다.
    """
    # Get recipe and verify ownership
    query = select(Recipe).options(
        selectinload(Recipe.user),
        selectinload(Recipe.reactions),
        selectinload(Recipe.bookmarks)
    ).where(Recipe.id == recipe_id)
    
    result = await db.execute(query)
    recipe = result.scalar_one_or_none()
    
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    
    if recipe.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="You don't have permission to modify this recipe")
    
    # Update visibility
    recipe.visibility = visibility_update.visibility
    await db.commit()
    await db.refresh(recipe)
    
    # Return updated recipe with community data
    reaction_counts = {}
    total_reactions = 0
    for reaction in recipe.reactions:
        reaction_type = reaction.reaction_type.value
        reaction_counts[reaction_type] = reaction_counts.get(reaction_type, 0) + 1
        total_reactions += 1
    
    is_bookmarked = any(bookmark.user_id == current_user.id for bookmark in recipe.bookmarks)
    
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
        visibility=recipe.visibility,
        created_at=recipe.created_at,
        updated_at=recipe.updated_at,
        author_name=recipe.user.full_name,
        reaction_counts=reaction_counts,
        total_reactions=total_reactions,
        is_bookmarked=is_bookmarked
    )


@router.post("/recipes/{recipe_id}/reactions", response_model=RecipeReactionResponse)
async def toggle_recipe_reaction(
    recipe_id: UUID,
    reaction_data: RecipeReactionCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    레시피에 리액션을 토글합니다 (추가/제거).
    """
    # Check if recipe exists and is accessible
    recipe_query = select(Recipe).where(
        and_(
            Recipe.id == recipe_id,
            or_(
                Recipe.visibility == RecipeVisibility.public,
                Recipe.visibility == RecipeVisibility.neighborhood,
                Recipe.visibility == RecipeVisibility.family
            )
        )
    )
    recipe_result = await db.execute(recipe_query)
    recipe = recipe_result.scalar_one_or_none()
    
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found or not accessible")
    
    # Check if user already has a reaction for this recipe
    existing_query = select(RecipeReaction).where(
        and_(
            RecipeReaction.recipe_id == recipe_id,
            RecipeReaction.user_id == current_user.id
        )
    )
    existing_result = await db.execute(existing_query)
    existing_reaction = existing_result.scalar_one_or_none()
    
    if existing_reaction:
        if existing_reaction.reaction_type == reaction_data.reaction_type:
            # Same reaction - remove it
            await db.delete(existing_reaction)
            await db.commit()
            raise HTTPException(status_code=204, detail="Reaction removed")
        else:
            # Different reaction - update it
            existing_reaction.reaction_type = reaction_data.reaction_type
            await db.commit()
            await db.refresh(existing_reaction)
            
            return RecipeReactionResponse(
                id=str(existing_reaction.id),
                recipe_id=str(existing_reaction.recipe_id),
                user_id=str(existing_reaction.user_id),
                reaction_type=existing_reaction.reaction_type,
                created_at=existing_reaction.created_at
            )
    else:
        # No existing reaction - create new one
        new_reaction = RecipeReaction(
            recipe_id=recipe_id,
            user_id=current_user.id,
            reaction_type=reaction_data.reaction_type
        )
        db.add(new_reaction)
        await db.commit()
        await db.refresh(new_reaction)
        
        return RecipeReactionResponse(
            id=str(new_reaction.id),
            recipe_id=str(new_reaction.recipe_id),
            user_id=str(new_reaction.user_id),
            reaction_type=new_reaction.reaction_type,
            created_at=new_reaction.created_at
        )


@router.post("/recipes/{recipe_id}/bookmark", response_model=RecipeBookmarkResponse)
async def toggle_recipe_bookmark(
    recipe_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    레시피 북마크를 토글합니다 (추가/제거).
    """
    # Check if recipe exists and is accessible
    recipe_query = select(Recipe).where(
        and_(
            Recipe.id == recipe_id,
            or_(
                Recipe.visibility == RecipeVisibility.public,
                Recipe.visibility == RecipeVisibility.neighborhood,
                Recipe.visibility == RecipeVisibility.family
            )
        )
    )
    recipe_result = await db.execute(recipe_query)
    recipe = recipe_result.scalar_one_or_none()
    
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found or not accessible")
    
    # Check if user already bookmarked this recipe
    existing_query = select(RecipeBookmark).where(
        and_(
            RecipeBookmark.recipe_id == recipe_id,
            RecipeBookmark.user_id == current_user.id
        )
    )
    existing_result = await db.execute(existing_query)
    existing_bookmark = existing_result.scalar_one_or_none()
    
    if existing_bookmark:
        # Remove bookmark
        await db.delete(existing_bookmark)
        await db.commit()
        raise HTTPException(status_code=204, detail="Bookmark removed")
    else:
        # Add bookmark
        new_bookmark = RecipeBookmark(
            recipe_id=recipe_id,
            user_id=current_user.id
        )
        db.add(new_bookmark)
        await db.commit()
        await db.refresh(new_bookmark)
        
        return RecipeBookmarkResponse(
            id=str(new_bookmark.id),
            recipe_id=str(new_bookmark.recipe_id),
            user_id=str(new_bookmark.user_id),
            created_at=new_bookmark.created_at
        )


@router.get("/bookmarks", response_model=List[RecipeResponse])
async def get_user_bookmarks(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    현재 사용자의 북마크한 레시피 목록을 조회합니다.
    """
    # Get bookmarked recipes
    query = select(Recipe).join(RecipeBookmark).options(
        selectinload(Recipe.user),
        selectinload(Recipe.reactions),
        selectinload(Recipe.bookmarks)
    ).where(
        RecipeBookmark.user_id == current_user.id
    ).order_by(
        RecipeBookmark.created_at.desc()
    )
    
    # Apply pagination
    offset = (page - 1) * limit
    query = query.offset(offset).limit(limit)
    
    result = await db.execute(query)
    recipes = result.scalars().all()
    
    # Convert to response format
    response_recipes = []
    for recipe in recipes:
        # Calculate reaction counts
        reaction_counts = {}
        total_reactions = 0
        for reaction in recipe.reactions:
            reaction_type = reaction.reaction_type.value
            reaction_counts[reaction_type] = reaction_counts.get(reaction_type, 0) + 1
            total_reactions += 1
        
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
            is_bookmarked=True  # All recipes in this list are bookmarked
        )
        response_recipes.append(recipe_response)
    
    return response_recipes