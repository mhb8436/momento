from sqlalchemy import Column, String, DateTime, Text, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from app.database import Base


class Recipe(Base):
    __tablename__ = "recipes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    source_audio_id = Column(UUID(as_uuid=True), ForeignKey("audio_files.id"), nullable=True)
    
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    ingredients = Column(JSON, nullable=True)  # [{"name": "양파", "amount": "1개", "notes": ""}]
    steps = Column(JSON, nullable=True)  # [{"step": 1, "instruction": "양파를 썰어주세요", "time": "5분"}]
    tips = Column(Text, nullable=True)
    servings = Column(String, nullable=True)  # "2-3인분"
    cooking_time = Column(String, nullable=True)  # "30분"
    difficulty = Column(String, nullable=True)  # "쉬움", "보통", "어려움"
    category = Column(String, nullable=True)  # "한식", "중식", "양식" 등
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="recipes")
    source_audio = relationship("AudioFile", back_populates="recipes")