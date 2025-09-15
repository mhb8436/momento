from openai import OpenAI
import json
from typing import Dict, Any, Optional
from app.config import settings

# OpenAI 클라이언트 초기화 (lazy initialization)
def get_openai_client():
    return OpenAI(api_key=settings.openai_api_key)


async def organize_recipe_from_text(transcript_text: str) -> Optional[Dict[str, Any]]:
    """
    OpenAI GPT를 사용하여 음성 텍스트를 구조화된 요리법으로 정리
    
    Args:
        transcript_text: STT로 변환된 텍스트
        
    Returns:
        구조화된 레시피 데이터 또는 None (실패시)
    """
    
    try:
        print(f"🔍 GPT 레시피 정리 시작: {transcript_text[:50]}...")
        
        # GPT에게 보낼 프롬프트 구성
        prompt = f"""
다음은 음성으로 녹음된 요리 과정입니다. 이를 바탕으로 구조화된 레시피를 만들어주세요.

음성 내용: "{transcript_text}"

다음 JSON 형식으로 응답해주세요:
{{
    "title": "요리명 (한국어, 간단하고 따뜻한 느낌으로)",
    "description": "요리 설명 (50자 내외, 가족의 정성이 담긴 느낌으로)",
    "ingredients": [
        {{"name": "재료명", "amount": "양", "notes": "부가설명"}},
        ...
    ],
    "steps": [
        {{"step": 1, "instruction": "조리 과정", "time": "소요시간", "tips": "팁"}},
        ...
    ],
    "tips": "전체적인 요리 팁 (한 줄로)",
    "servings": "인분 (예: 2-3인분)",
    "cooking_time": "총 조리시간",
    "difficulty": "쉬움/보통/어려움 중 하나",
    "category": "한식/중식/양식/일식/기타 중 하나"
}}

주의사항:
1. 재료의 양은 구체적으로 추정해서 작성
2. 조리 과정은 순서대로 상세하게 작성
3. 각 단계별 팁은 실용적으로 작성
4. 모든 내용은 한국어로 작성
5. JSON 형식을 정확히 지켜주세요
"""

        client = get_openai_client()
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7,
            max_tokens=1500
        )
        
        # 응답에서 JSON 부분 추출
        response_text = response.choices[0].message.content.strip()
        print(f"🔍 GPT 응답: {response_text[:100]}...")
        
        # JSON 파싱
        try:
            # JSON 시작과 끝 찾기
            start_idx = response_text.find('{')
            end_idx = response_text.rfind('}') + 1
            
            if start_idx != -1 and end_idx != 0:
                json_str = response_text[start_idx:end_idx]
                recipe_data = json.loads(json_str)
                
                # 필수 필드 검증
                required_fields = ['title', 'ingredients', 'steps']
                if all(field in recipe_data for field in required_fields):
                    print(f"✅ GPT 레시피 정리 완료: {recipe_data['title']}")
                    return recipe_data
                else:
                    print(f"❌ 필수 필드 누락: {required_fields}")
                    return None
            else:
                print("❌ JSON 형식을 찾을 수 없음")
                return None
                
        except json.JSONDecodeError as e:
            print(f"❌ JSON 파싱 오류: {e}")
            print(f"원본 응답: {response_text}")
            return None
        
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