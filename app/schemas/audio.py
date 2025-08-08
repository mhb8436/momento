from pydantic import BaseModel
from typing import Optional


class TextProcessRequest(BaseModel):
    transcript: str


class TextProcessResponse(BaseModel):
    transcript: str
    processing_status: str
    recipe_id: Optional[str] = None