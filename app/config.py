from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    database_url: str
    secret_key: str
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 1440  # 24시간
    openai_api_key: str
    firebase_service_account_path: Optional[str] = None
    youtube_api_key: Optional[str] = None
    env: str = "development"
    
    class Config:
        env_file = ".env"


settings = Settings()