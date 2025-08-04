import httpx
from openai import OpenAI
from pathlib import Path
from typing import Optional
from app.config import settings

# OpenAI 클라이언트 초기화 (lazy initialization)
def get_openai_client():
    """Create OpenAI client with custom HTTP client to avoid proxy issues"""
    http_client = httpx.Client()
    return OpenAI(
        api_key=settings.openai_api_key,
        http_client=http_client
    )


async def transcribe_audio(file_path: str) -> Optional[str]:
    """
    목업 STT 서비스 (개발용)
    실제 환경에서는 OpenAI Whisper API를 사용
    
    Args:
        file_path: 오디오 파일 경로
        
    Returns:
        변환된 텍스트 또는 None (실패시)
    """
    try:
        print(f"🔍 STT 처리 시작 (목업 모드): {file_path}")
        audio_file_path = Path(file_path)
        
        if not audio_file_path.exists():
            print(f"❌ 파일이 존재하지 않음: {file_path}")
            raise FileNotFoundError(f"Audio file not found: {file_path}")
        
        file_size = audio_file_path.stat().st_size
        print(f"🔍 파일 크기: {file_size} bytes")
        
        # 목업 데이터: 실제 음성 인식 결과 대신 샘플 레시피 텍스트 반환
        import time
        import random
        
        # 실제 API 호출을 시뮬레이션하기 위한 지연
        print("🔍 목업 STT 처리 중... (1초 대기)")
        time.sleep(1)
        
        # 샘플 레시피 텍스트들
        sample_recipes = [
            "오늘은 김치찌개를 만들어보겠습니다. 재료는 김치 200그램, 돼지고기 150그램, 두부 반 모, 대파 1대, 마늘 3쪽이 필요해요. 먼저 팬에 기름을 두르고 돼지고기를 볶아주세요. 고기가 익으면 김치를 넣고 함께 볶아주고요. 물을 넣고 끓이다가 두부와 대파를 넣어서 5분 정도 더 끓이면 완성입니다.",
            
            "간단한 계란볶음밥을 만들어보겠습니다. 밥 2공기, 계란 3개, 당근 반 개, 양파 반 개, 파 조금 준비해주세요. 팬에 기름을 두르고 계란을 스크램블해서 먼저 꺼내두고요. 같은 팬에 양파와 당근을 볶다가 밥을 넣고 볶아주세요. 마지막에 계란과 파를 넣고 간장으로 간을 맞추면 됩니다.",
            
            "된장찌개 만드는 법입니다. 된장 2큰술, 호박 반 개, 양파 반 개, 두부 반 모, 멸치육수 2컵이 필요해요. 먼저 멸치육수를 끓이고 된장을 풀어주세요. 호박과 양파를 넣고 끓이다가 두부를 마지막에 넣어서 한소끔 끓이면 완성입니다. 마늘과 파를 넣으면 더 맛있어요."
        ]
        
        # 랜덤하게 샘플 레시피 선택
        mock_transcript = random.choice(sample_recipes)
        
        print(f"✅ 목업 STT 성공, 텍스트 길이: {len(mock_transcript)} 문자")
        print(f"🔍 생성된 텍스트: {mock_transcript[:50]}...")
        
        return mock_transcript
        
    except FileNotFoundError as e:
        print(f"❌ STT 파일 오류: {e}")
        return None
    except Exception as e:
        print(f"❌ STT 상세 오류:")
        print(f"   오류 타입: {type(e).__name__}")
        print(f"   오류 메시지: {str(e)}")
        import traceback
        print(f"   스택 트레이스: {traceback.format_exc()}")
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