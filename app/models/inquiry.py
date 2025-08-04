from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Enum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum

from app.database import Base


class InquiryStatus(str, enum.Enum):
    PENDING = "pending"
    ANSWERED = "answered"
    CLOSED = "closed"


class InquiryCategory(str, enum.Enum):
    GENERAL = "general"
    BUG = "bug"
    FEATURE = "feature"
    ACCOUNT = "account"
    RECIPE = "recipe"
    AUDIO = "audio"
    UI = "ui"
    PERFORMANCE = "performance"


class Inquiry(Base):
    __tablename__ = "inquiries"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # 문의사항 내용
    title = Column(String(200), nullable=False)
    content = Column(Text, nullable=False)
    category = Column(Enum(InquiryCategory), nullable=False, default=InquiryCategory.GENERAL)
    
    # 상태 관리
    status = Column(Enum(InquiryStatus), nullable=False, default=InquiryStatus.PENDING)
    
    # 관리자 답변
    admin_response = Column(Text, nullable=True)
    admin_response_at = Column(DateTime, nullable=True)
    admin_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    
    # 타임스탬프
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 관계
    user = relationship("User", foreign_keys=[user_id], back_populates="inquiries")
    admin = relationship("User", foreign_keys=[admin_id])
    
    def __repr__(self):
        return f"<Inquiry {self.title}>"