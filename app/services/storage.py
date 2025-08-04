import os
import uuid
from pathlib import Path
from fastapi import UploadFile
from typing import Tuple

UPLOAD_DIR = Path("uploads/audio")
PROFILE_UPLOAD_DIR = Path("uploads/profiles")


def ensure_upload_dir(upload_dir: Path = UPLOAD_DIR):
    """업로드 디렉토리가 존재하는지 확인하고 없으면 생성"""
    upload_dir.mkdir(parents=True, exist_ok=True)


async def save_uploaded_file(file: UploadFile, user_id: str) -> Tuple[str, str, int]:
    """
    오디오 파일을 저장하고 파일 정보를 반환
    
    Returns:
        Tuple[file_path, file_name, file_size]
    """
    ensure_upload_dir(UPLOAD_DIR)
    
    # 고유한 파일명 생성
    file_extension = Path(file.filename).suffix if file.filename else ".wav"
    unique_filename = f"{user_id}_{uuid.uuid4().hex}{file_extension}"
    file_path = UPLOAD_DIR / unique_filename
    
    # 파일 저장
    content = await file.read()
    file_size = len(content)
    
    with open(file_path, "wb") as buffer:
        buffer.write(content)
    
    return str(file_path), file.filename or unique_filename, file_size


async def save_profile_image(file: UploadFile, user_id: str) -> Tuple[str, str, int]:
    """
    프로필 이미지를 저장하고 파일 정보를 반환
    
    Returns:
        Tuple[file_path, file_name, file_size]
    """
    ensure_upload_dir(PROFILE_UPLOAD_DIR)
    
    # 고유한 파일명 생성
    file_extension = Path(file.filename).suffix if file.filename else ".jpg"
    unique_filename = f"{user_id}_{uuid.uuid4().hex}{file_extension}"
    file_path = PROFILE_UPLOAD_DIR / unique_filename
    
    # 파일 저장
    content = await file.read()
    file_size = len(content)
    
    with open(file_path, "wb") as buffer:
        buffer.write(content)
    
    return str(file_path), unique_filename, file_size


def get_file_path(file_path: str) -> Path:
    """저장된 파일의 전체 경로 반환"""
    return Path(file_path)


def delete_file(file_path: str) -> bool:
    """파일 삭제"""
    try:
        Path(file_path).unlink(missing_ok=True)
        return True
    except Exception:
        return False