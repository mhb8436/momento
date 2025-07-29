import openai
from pathlib import Path
from typing import Optional
from app.config import settings

# OpenAI 클라이언트 초기화
client = openai.OpenAI(api_key=settings.openai_api_key)


async def transcribe_audio(file_path: str) -> Optional[str]:
    """
    OpenAI Whisper API를 사용하여 오디오 파일을 텍스트로 변환
    
    Args:
        file_path: 오디오 파일 경로
        
    Returns:
        변환된 텍스트 또는 None (실패시)
    """
    try:
        audio_file_path = Path(file_path)
        
        if not audio_file_path.exists():
            raise FileNotFoundError(f"Audio file not found: {file_path}")
        
        with open(audio_file_path, "rb") as audio_file:
            transcript = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                language="ko"  # 한국어 지정
            )
        
        return transcript.text
        
    except Exception as e:
        print(f"STT Error: {e}")
        return None


def get_audio_duration(file_path: str) -> Optional[int]:
    """
    오디오 파일의 길이를 초 단위로 반환
    실제 구현시에는 librosa, mutagen 등의 라이브러리 사용 권장
    """
    try:
        # 임시로 파일 크기 기반 추정 (실제로는 오디오 라이브러리 사용)
        file_size = Path(file_path).stat().st_size
        # 대략적인 추정: 1MB당 60초 (실제 값과 다를 수 있음)
        estimated_duration = int(file_size / (1024 * 1024) * 60)
        return max(1, estimated_duration)  # 최소 1초
    except Exception:
        return None