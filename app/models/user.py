from sqlalchemy import Column, String, DateTime, Boolean, Enum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
import enum
from app.database import Base


class UserRole(str, enum.Enum):
    USER = "user"
    ADMIN = "admin"
    SUPER_ADMIN = "super_admin"


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    full_name = Column(String, nullable=True)
    profile_image_url = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    
    # 관리자 역할 관리
    role = Column(Enum(UserRole), nullable=False, default=UserRole.USER)
    is_admin = Column(Boolean, default=False)  # 빠른 확인용
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    recipes = relationship("Recipe", back_populates="user", cascade="all, delete-orphan")
    inquiries = relationship("Inquiry", foreign_keys="Inquiry.user_id", back_populates="user", cascade="all, delete-orphan")
    fcm_tokens = relationship("FCMToken", back_populates="user", cascade="all, delete-orphan")
    notification_logs = relationship("NotificationLog", back_populates="user", cascade="all, delete-orphan")
    recipe_reactions = relationship("RecipeReaction", back_populates="user", cascade="all, delete-orphan")
    recipe_bookmarks = relationship("RecipeBookmark", back_populates="user", cascade="all, delete-orphan")
    
    # 크레딧 시스템 관계
    credit_info = relationship("UserCredit", back_populates="user", uselist=False, cascade="all, delete-orphan", lazy="select")
    
    # 편의 메서드
    def is_admin_user(self) -> bool:
        """관리자인지 확인"""
        return self.role in [UserRole.ADMIN, UserRole.SUPER_ADMIN]
    
    def is_super_admin_user(self) -> bool:
        """슈퍼 관리자인지 확인"""
        return self.role == UserRole.SUPER_ADMIN
    
    def __repr__(self):
        return f"<User {self.email} ({self.role})>"