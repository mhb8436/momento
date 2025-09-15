from sqlalchemy import Column, String, DateTime, Text, ForeignKey, JSON, Enum, Integer, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
import enum
from app.database import Base


class RecipeVisibility(enum.Enum):
    private = "private"
    family = "family" 
    neighborhood = "neighborhood"
    public = "public"


class ReactionType(enum.Enum):
    warm = "warm"
    delicious = "delicious"
    nostalgic = "nostalgic"
    family_loved = "family_loved"
    want_to_try = "want_to_try"


class Recipe(Base):
    __tablename__ = "recipes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    ingredients = Column(JSON, nullable=True)  # [{"name": "양파", "amount": "1개", "notes": ""}]
    steps = Column(JSON, nullable=True)  # [{"step": 1, "instruction": "양파를 썰어주세요", "time": "5분"}]
    tips = Column(Text, nullable=True)
    servings = Column(String, nullable=True)  # "2-3인분"
    cooking_time = Column(String, nullable=True)  # "30분"
    difficulty = Column(String, nullable=True)  # "쉬움", "보통", "어려움"
    category = Column(String, nullable=True)  # "한식", "중식", "양식" 등
    image_url = Column(String, nullable=True)  # 레시피 이미지 URL
    
    # 공유 시스템 필드들
    visibility = Column(Enum(RecipeVisibility), nullable=False, default=RecipeVisibility.private)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="recipes")
    reactions = relationship("RecipeReaction", back_populates="recipe", cascade="all, delete-orphan")
    bookmarks = relationship("RecipeBookmark", back_populates="recipe", cascade="all, delete-orphan")


class RecipeReaction(Base):
    __tablename__ = "recipe_reactions"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    recipe_id = Column(UUID(as_uuid=True), ForeignKey("recipes.id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    reaction_type = Column(Enum(ReactionType), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    recipe = relationship("Recipe", back_populates="reactions")
    user = relationship("User", back_populates="recipe_reactions")


class RecipeBookmark(Base):
    __tablename__ = "recipe_bookmarks"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    recipe_id = Column(UUID(as_uuid=True), ForeignKey("recipes.id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    recipe = relationship("Recipe", back_populates="bookmarks")
    user = relationship("User", back_populates="recipe_bookmarks")