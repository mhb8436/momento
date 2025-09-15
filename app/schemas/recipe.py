from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum


class RecipeVisibility(str, Enum):
    private = "private"
    family = "family"
    neighborhood = "neighborhood"
    public = "public"


class ReactionType(str, Enum):
    warm = "warm"
    delicious = "delicious"
    nostalgic = "nostalgic"
    family_loved = "family_loved"
    want_to_try = "want_to_try"


class RecipeCreate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    ingredients: Optional[List[Dict[str, Any]]] = None
    steps: Optional[List[Dict[str, Any]]] = None
    tips: Optional[str] = None
    servings: Optional[str] = None
    cooking_time: Optional[str] = None
    difficulty: Optional[str] = None
    category: Optional[str] = None
    visibility: Optional[RecipeVisibility] = RecipeVisibility.private


class RecipeIngredient(BaseModel):
    name: str
    amount: str
    notes: Optional[str] = None


class RecipeStep(BaseModel):
    step: int
    instruction: str
    time: Optional[str] = None
    temperature: Optional[str] = None
    tips: Optional[str] = None


class RecipeReactionCreate(BaseModel):
    reaction_type: ReactionType


class RecipeReactionResponse(BaseModel):
    id: str
    recipe_id: str
    user_id: str
    reaction_type: ReactionType
    created_at: datetime

    class Config:
        from_attributes = True


class RecipeBookmarkResponse(BaseModel):
    id: str
    recipe_id: str
    user_id: str
    created_at: datetime

    class Config:
        from_attributes = True


class RecipeResponse(BaseModel):
    id: str
    user_id: str
    title: str
    description: Optional[str] = None
    ingredients: Optional[List[Dict[str, Any]]] = None
    steps: Optional[List[Dict[str, Any]]] = None
    tips: Optional[str] = None
    servings: Optional[str] = None
    cooking_time: Optional[str] = None
    difficulty: Optional[str] = None
    category: Optional[str] = None
    image_url: Optional[str] = None
    visibility: RecipeVisibility
    created_at: datetime
    updated_at: datetime
    
    # 커뮤니티 관련 필드들
    author_name: Optional[str] = None
    reaction_counts: Optional[Dict[str, int]] = None
    total_reactions: Optional[int] = None
    is_bookmarked: Optional[bool] = None

    class Config:
        from_attributes = True


class RecipeUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    ingredients: Optional[List[Dict[str, Any]]] = None
    steps: Optional[List[Dict[str, Any]]] = None
    tips: Optional[str] = None
    servings: Optional[str] = None
    cooking_time: Optional[str] = None
    difficulty: Optional[str] = None
    category: Optional[str] = None
    image_url: Optional[str] = None
    visibility: Optional[RecipeVisibility] = None


class RecipeVisibilityUpdate(BaseModel):
    visibility: RecipeVisibility