from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime


class RecipeCreate(BaseModel):
    source_audio_id: str


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


class RecipeResponse(BaseModel):
    id: str
    user_id: str
    source_audio_id: Optional[str] = None
    title: str
    description: Optional[str] = None
    ingredients: Optional[List[Dict[str, Any]]] = None
    steps: Optional[List[Dict[str, Any]]] = None
    tips: Optional[str] = None
    servings: Optional[str] = None
    cooking_time: Optional[str] = None
    difficulty: Optional[str] = None
    category: Optional[str] = None
    created_at: datetime
    updated_at: datetime

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