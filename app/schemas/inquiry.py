from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from datetime import datetime
from app.models.inquiry import InquiryStatus, InquiryCategory


class InquiryBase(BaseModel):
    title: str
    content: str
    category: InquiryCategory


class InquiryCreate(InquiryBase):
    pass


class InquiryUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    category: Optional[InquiryCategory] = None


class AdminResponseCreate(BaseModel):
    admin_response: str


class AdminResponseUpdate(BaseModel):
    admin_response: Optional[str] = None
    status: Optional[InquiryStatus] = None


class InquiryResponse(InquiryBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: str
    user_id: str
    status: InquiryStatus
    admin_response: Optional[str] = None
    admin_response_at: Optional[datetime] = None
    admin_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class InquiryListResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: str
    title: str
    category: InquiryCategory
    status: InquiryStatus
    created_at: datetime
    updated_at: datetime
    has_response: bool = False
    
    def __init__(self, **data):
        super().__init__(**data)
        self.has_response = bool(data.get('admin_response'))


class InquiryStatsResponse(BaseModel):
    total: int
    pending: int
    answered: int
    closed: int