from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime
from uuid import UUID
from app.models.notification import NotificationType


class FCMTokenRegister(BaseModel):
    fcm_token: str
    device_type: Optional[str] = None


class FCMTokenResponse(BaseModel):
    id: UUID
    user_id: UUID
    token: str
    device_type: Optional[str]
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True


class NotificationSend(BaseModel):
    user_ids: list[UUID]
    notification_type: NotificationType
    title: str
    body: str
    data: Optional[Dict[str, Any]] = None


class NotificationBroadcast(BaseModel):
    notification_type: NotificationType
    title: str
    body: str
    data: Optional[Dict[str, Any]] = None


class NotificationLogResponse(BaseModel):
    id: UUID
    user_id: UUID
    notification_type: NotificationType
    title: str
    body: str
    data: Optional[str]
    sent_at: datetime
    is_read: bool
    read_at: Optional[datetime]

    class Config:
        from_attributes = True


class NotificationReadRequest(BaseModel):
    notification_ids: list[UUID]