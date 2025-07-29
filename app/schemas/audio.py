from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class AudioFileResponse(BaseModel):
    id: str
    user_id: str
    file_name: str
    file_size: Optional[int] = None
    duration: Optional[int] = None
    transcript_text: Optional[str] = None
    processing_status: str
    created_at: datetime

    class Config:
        from_attributes = True


class AudioProcessRequest(BaseModel):
    audio_id: str


class AudioProcessResponse(BaseModel):
    audio_id: str
    transcript_text: str
    processing_status: str