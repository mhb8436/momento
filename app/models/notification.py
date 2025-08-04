from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Text, Boolean, ForeignKey, Enum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base
import enum
import uuid


class NotificationType(str, enum.Enum):
    INQUIRY_ANSWER = "inquiry_answer"
    APP_UPDATE = "app_update"
    RECIPE_RECOMMENDATION = "recipe_recommendation"
    SYSTEM_MAINTENANCE = "system_maintenance"


class FCMToken(Base):
    __tablename__ = "fcm_tokens"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    token = Column(String(500), nullable=False, unique=True)
    device_type = Column(String(50))  # 'android' or 'ios'
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="fcm_tokens")


class NotificationLog(Base):
    __tablename__ = "notification_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    notification_type = Column(Enum(NotificationType), nullable=False)
    title = Column(String(200), nullable=False)
    body = Column(Text, nullable=False)
    data = Column(Text)  # JSON string for additional data
    sent_at = Column(DateTime(timezone=True), server_default=func.now())
    is_read = Column(Boolean, default=False)
    read_at = Column(DateTime(timezone=True))

    # Relationships
    user = relationship("User", back_populates="notification_logs")