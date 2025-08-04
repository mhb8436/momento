from openai import OpenAI
import json
from typing import Dict, Any, Optional
from app.config import settings

# OpenAI 클라이언트 초기화 (lazy initialization)
def get_openai_client():
    return OpenAI(api_key=settings.openai_api_key)


async def organize_recipe_from_text(transcript_text: str) -> Optional[Dict[str, Any]]:
    """
    목업 GPT 서비스 (개발용)
    음성 텍스트를 구조화된 요리법으로 정리
    
    Args:
        transcript_text: STT로 변환된 텍스트
        
    Returns:
        구조화된 레시피 데이터 또는 None (실패시)
    """
    
    try:
        print(f"🔍 GPT 레시피 정리 시작 (목업 모드): {transcript_text[:50]}...")
        
        # 텍스트 분석하여 적절한 목업 레시피 생성
        import time
        time.sleep(0.5)  # API 호출 시뮬레이션
        
        # 키워드 기반으로 레시피 종류 판별
        if "김치찌개" in transcript_text:
            recipe_data = {
                "title": "엄마표 김치찌개",
                "description": "깊은 맛이 일품인 우리 집 김치찌개입니다.",
                "ingredients": [
                    {"name": "김치", "amount": "200g", "notes": "잘 익은 것으로"},
                    {"name": "돼지고기", "amount": "150g", "notes": "목살 또는 삼겹살"},
                    {"name": "두부", "amount": "1/2모", "notes": ""},
                    {"name": "대파", "amount": "1대", "notes": ""},
                    {"name": "마늘", "amount": "3쪽", "notes": "다진 것"}
                ],
                "steps": [
                    {"step": 1, "instruction": "팬에 기름을 두르고 돼지고기를 볶아주세요", "time": "3분", "tips": "고기가 완전히 익을 때까지"},
                    {"step": 2, "instruction": "김치를 넣고 함께 볶아주세요", "time": "2분", "tips": "김치의 신맛이 날아갈 때까지"},
                    {"step": 3, "instruction": "물을 넣고 끓여주세요", "time": "10분", "tips": "김치국물도 함께 넣으면 더 맛있어요"},
                    {"step": 4, "instruction": "두부와 대파를 넣고 5분 더 끓이면 완성", "time": "5분", "tips": "두부는 마지막에 넣어야 부서지지 않아요"}
                ],
                "tips": "김치는 잘 익은 것을 사용하고, 김치국물도 함께 넣으면 훨씬 맛있습니다",
                "servings": "2-3인분",
                "cooking_time": "20분",
                "difficulty": "쉬움",
                "category": "한식"
            }
        elif "계란볶음밥" in transcript_text:
            recipe_data = {
                "title": "간단한 계란볶음밥",
                "description": "남은 밥으로 만드는 맛있는 볶음밥입니다.",
                "ingredients": [
                    {"name": "밥", "amount": "2공기", "notes": "차가운 밥이 좋아요"},
                    {"name": "계란", "amount": "3개", "notes": ""},
                    {"name": "당근", "amount": "1/2개", "notes": "잘게 다진 것"},
                    {"name": "양파", "amount": "1/2개", "notes": "잘게 다진 것"},
                    {"name": "파", "amount": "조금", "notes": "송송 썬 것"}
                ],
                "steps": [
                    {"step": 1, "instruction": "팬에 기름을 두르고 계란을 스크램블해서 먼저 꺼내두세요", "time": "2분", "tips": "완전히 익히지 말고 반숙으로"},
                    {"step": 2, "instruction": "같은 팬에 양파와 당근을 볶아주세요", "time": "3분", "tips": "양파가 투명해질 때까지"},
                    {"step": 3, "instruction": "밥을 넣고 볶아주세요", "time": "5분", "tips": "밥알이 고슬고슬하게"},
                    {"step": 4, "instruction": "계란과 파를 넣고 간장으로 간을 맞추면 완성", "time": "2분", "tips": "간장은 조금씩 넣어가며 맛을 보세요"}
                ],
                "tips": "찬밥을 사용하면 더 고슬고슬하고, 계란은 마지막에 넣어야 부드러워요",
                "servings": "2인분",
                "cooking_time": "12분",
                "difficulty": "쉬움",
                "category": "한식"
            }
        elif "된장찌개" in transcript_text:
            recipe_data = {
                "title": "구수한 된장찌개",
                "description": "구수하고 깊은 맛의 우리 집 된장찌개입니다.",
                "ingredients": [
                    {"name": "된장", "amount": "2큰술", "notes": "좋은 된장으로"},
                    {"name": "호박", "amount": "1/2개", "notes": "적당한 크기로 썰기"},
                    {"name": "양파", "amount": "1/2개", "notes": ""},
                    {"name": "두부", "amount": "1/2모", "notes": ""},
                    {"name": "멸치육수", "amount": "2컵", "notes": "멸치와 다시마로 우린 것"}
                ],
                "steps": [
                    {"step": 1, "instruction": "멸치육수를 끓이고 된장을 풀어주세요", "time": "3분", "tips": "된장은 체에 걸러서 풀면 더 깔끔해요"},
                    {"step": 2, "instruction": "호박과 양파를 넣고 끓여주세요", "time": "5분", "tips": "호박이 반투명해질 때까지"},
                    {"step": 3, "instruction": "두부를 넣고 한소끔 더 끓이면 완성", "time": "3분", "tips": "두부는 너무 오래 끓이지 마세요"}
                ],
                "tips": "마늘과 파를 넣으면 더 맛있고, 된장은 좋은 것을 사용하는 것이 중요해요",
                "servings": "2-3인분",
                "cooking_time": "11분",
                "difficulty": "쉬움",
                "category": "한식"
            }
        else:
            # 기본 레시피 구조
            recipe_data = {
                "title": "전통 가정식 레시피",
                "description": "우리 가족만의 특별한 레시피입니다.",
                "ingredients": [
                    {"name": "주재료", "amount": "적당량", "notes": "신선한 것으로 준비"},
                    {"name": "부재료", "amount": "조금", "notes": ""}
                ],
                "steps": [
                    {"step": 1, "instruction": "재료를 준비합니다", "time": "5분", "tips": ""},
                    {"step": 2, "instruction": "조리를 시작합니다", "time": "10분", "tips": ""},
                    {"step": 3, "instruction": "맛을 조절하고 완성합니다", "time": "5분", "tips": ""}
                ],
                "tips": transcript_text,  # 원본 텍스트를 팁으로 저장
                "servings": "2-3인분",
                "cooking_time": "20분",
                "difficulty": "보통",
                "category": "한식"
            }
        
        print(f"✅ GPT 레시피 정리 완료: {recipe_data['title']}")
        return recipe_data
        
    except Exception as e:
        print(f"❌ GPT 레시피 정리 오류: {e}")
        return None


async def improve_recipe_description(recipe_data: Dict[str, Any]) -> Optional[str]:
    """
    기존 레시피를 바탕으로 더 자세한 설명을 생성
    """
    
    prompt = f"""
다음 레시피를 바탕으로 따뜻하고 감성적인 요리 설명을 작성해주세요. 
가족의 정성과 사랑이 담긴 느낌으로 100자 내외로 작성해주세요.

요리명: {recipe_data.get('title', '')}
재료: {', '.join([ing.get('name', '') for ing in recipe_data.get('ingredients', [])])}
특징: {recipe_data.get('tips', '')}
"""

    try:
        client = get_openai_client()
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7,
            max_tokens=200
        )
        
        return response.choices[0].message.content.strip()
        
    except Exception as e:
        print(f"Description generation error: {e}")
        return None