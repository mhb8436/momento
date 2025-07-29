from openai import OpenAI
import json
from typing import Dict, Any, Optional
from app.config import settings

# OpenAI 클라이언트 초기화 (lazy initialization)
def get_openai_client():
    return OpenAI(api_key=settings.openai_api_key)


async def organize_recipe_from_text(transcript_text: str) -> Optional[Dict[str, Any]]:
    """
    GPT를 사용하여 음성 텍스트를 구조화된 요리법으로 정리
    
    Args:
        transcript_text: STT로 변환된 텍스트
        
    Returns:
        구조화된 레시피 데이터 또는 None (실패시)
    """
    
    system_prompt = """
당신은 한국의 요리 전문가입니다. 사용자가 말로 설명한 요리법을 듣고, 이를 체계적이고 따라하기 쉬운 레시피로 정리해주세요.

다음 JSON 형식으로 응답해주세요:

{
  "title": "요리 이름",
  "description": "요리에 대한 간단한 설명",
  "ingredients": [
    {
      "name": "재료명",
      "amount": "분량",
      "notes": "특별한 주의사항이나 팁 (선택적)"
    }
  ],
  "steps": [
    {
      "step": 1,
      "instruction": "단계별 요리 방법",
      "time": "예상 소요 시간 (선택적)",
      "temperature": "온도 설정 (선택적)",
      "tips": "해당 단계의 팁 (선택적)"
    }
  ],
  "tips": "전체적인 요리 팁이나 주의사항",
  "servings": "몇 인분",
  "cooking_time": "총 조리 시간",
  "difficulty": "쉬움/보통/어려움",
  "category": "한식/중식/양식/일식/기타"
}

중요한 점:
1. 재료의 분량은 구체적으로 적어주세요 (예: "양파 1개", "소금 1작은술")
2. 조리 순서는 명확하고 따라하기 쉽게 작성해주세요
3. 온도나 시간이 언급되면 정확히 포함해주세요
4. 엄마만의 특별한 팁이나 비법이 있다면 tips에 포함해주세요
5. JSON 형식을 정확히 지켜주세요
"""

    user_prompt = f"""
다음은 어머니가 설명해주신 요리법입니다. 이를 체계적인 레시피로 정리해주세요:

"{transcript_text}"
"""

    try:
        client = get_openai_client()
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            temperature=0.3,  # 일관성을 위해 낮은 온도 설정
            max_tokens=2000
        )
        
        # GPT 응답에서 JSON 추출
        content = response.choices[0].message.content.strip()
        
        # JSON 부분만 추출 (```json ... ``` 형태로 감싸져있을 수 있음)
        if "```json" in content:
            start = content.find("```json") + 7
            end = content.find("```", start)
            json_content = content[start:end].strip()
        elif content.startswith("{") and content.endswith("}"):
            json_content = content
        else:
            # JSON 형태가 아닌 경우 기본 구조로 래핑
            return {
                "title": "정리된 레시피",
                "description": content,
                "ingredients": [],
                "steps": [],
                "tips": content,
                "servings": "2-3인분",
                "cooking_time": "30분",
                "difficulty": "보통",
                "category": "기타"
            }
        
        recipe_data = json.loads(json_content)
        
        # 필수 필드 검증 및 기본값 설정
        required_fields = {
            "title": "정리된 레시피",
            "description": "",
            "ingredients": [],
            "steps": [],
            "tips": "",
            "servings": "2-3인분",
            "cooking_time": "30분",
            "difficulty": "보통",
            "category": "기타"
        }
        
        for field, default_value in required_fields.items():
            if field not in recipe_data:
                recipe_data[field] = default_value
        
        return recipe_data
        
    except json.JSONDecodeError as e:
        print(f"JSON parsing error: {e}")
        # JSON 파싱 실패시 기본 구조 반환
        return {
            "title": "정리된 레시피",
            "description": transcript_text[:200] + "..." if len(transcript_text) > 200 else transcript_text,
            "ingredients": [],
            "steps": [],
            "tips": transcript_text,
            "servings": "2-3인분",
            "cooking_time": "30분",
            "difficulty": "보통",
            "category": "기타"
        }
        
    except Exception as e:
        print(f"GPT processing error: {e}")
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