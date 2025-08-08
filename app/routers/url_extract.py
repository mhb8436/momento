from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, HttpUrl
import httpx
import re
import os
from typing import Optional
import logging
from bs4 import BeautifulSoup

from ..utils.dependencies import get_current_user
from ..schemas.auth import UserResponse

router = APIRouter(prefix="/url-extract", tags=["url-extract"])
logger = logging.getLogger(__name__)

# YouTube API 설정
YOUTUBE_API_KEY = os.getenv("YOUTUBE_API_KEY")
YOUTUBE_API_BASE_URL = "https://www.googleapis.com/youtube/v3"

class UrlExtractionRequest(BaseModel):
    url: HttpUrl
    
class UrlExtractionResponse(BaseModel):
    success: bool
    content: Optional[str] = None
    title: Optional[str] = None
    site_type: Optional[str] = None
    error: Optional[str] = None

def extract_youtube_video_id(url: str) -> Optional[str]:
    """YouTube URL에서 비디오 ID 추출"""
    patterns = [
        r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/v\/)([^&\n?#]+)',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, url, re.IGNORECASE)
        if match:
            return match.group(1)
    return None

async def extract_youtube_content(url: str) -> UrlExtractionResponse:
    """YouTube API를 통해 비디오 정보 추출"""
    try:
        video_id = extract_youtube_video_id(url)
        if not video_id:
            return UrlExtractionResponse(
                success=False, 
                error="올바른 YouTube URL이 아닙니다."
            )
        
        if not YOUTUBE_API_KEY:
            logger.warning("YouTube API key not configured, falling back to HTML parsing")
            return await extract_youtube_html(url)
        
        # YouTube API 호출
        async with httpx.AsyncClient() as client:
            api_url = f"{YOUTUBE_API_BASE_URL}/videos"
            params = {
                "part": "snippet",
                "id": video_id,
                "key": YOUTUBE_API_KEY
            }
            
            response = await client.get(api_url, params=params)
            response.raise_for_status()
            
            data = response.json()
            
            if not data.get("items"):
                return UrlExtractionResponse(
                    success=False,
                    error="비디오를 찾을 수 없습니다."
                )
            
            video = data["items"][0]
            snippet = video["snippet"]
            
            # 레시피 내용 추출
            description = snippet.get("description", "")
            recipe_content = extract_recipe_from_description(description)
            
            # 결과 구성
            content_parts = [
                f"🎥 {snippet.get('title', '')}",
                f"📺 {snippet.get('channelTitle', '')}",
                "",
            ]
            
            if recipe_content:
                content_parts.extend([
                    "📝 설명란에서 추출한 레시피:",
                    recipe_content
                ])
            else:
                content_parts.extend([
                    "📝 영상 설명:",
                    description[:1000] + ("..." if len(description) > 1000 else "")
                ])
            
            return UrlExtractionResponse(
                success=True,
                content="\n".join(content_parts),
                title=snippet.get("title"),
                site_type="YouTube"
            )
            
    except httpx.HTTPError as e:
        logger.error(f"YouTube API 호출 실패: {e}")
        return UrlExtractionResponse(
            success=False,
            error=f"YouTube API 호출 실패: {str(e)}"
        )
    except Exception as e:
        logger.error(f"YouTube 콘텐츠 추출 오류: {e}")
        return UrlExtractionResponse(
            success=False,
            error=f"YouTube 콘텐츠 추출 오류: {str(e)}"
        )

async def extract_youtube_html(url: str) -> UrlExtractionResponse:
    """HTML 파싱을 통한 YouTube 콘텐츠 추출 (폴백)"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(str(url))
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # 제목 추출
            title_tag = soup.find('title')
            title = title_tag.text if title_tag else ""
            
            # 메타 설명 추출
            description_meta = soup.find('meta', {'name': 'description'})
            description = description_meta.get('content', '') if description_meta else ""
            
            content = f"🎥 {title}\n\n📝 영상 설명:\n{description}"
            
            return UrlExtractionResponse(
                success=True,
                content=content,
                title=title,
                site_type="YouTube (HTML)"
            )
            
    except Exception as e:
        logger.error(f"YouTube HTML 파싱 오류: {e}")
        return UrlExtractionResponse(
            success=False,
            error=f"YouTube HTML 파싱 오류: {str(e)}"
        )

def extract_recipe_from_description(description: str) -> str:
    """영상 설명에서 레시피 관련 내용만 추출"""
    if not description:
        return ""
    
    lines = description.split('\n')
    recipe_content = []
    found_recipe_section = False
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # 레시피 관련 키워드 검색
        if re.search(r'재료|ingredient|만드는|레시피|recipe|조리|요리', line, re.IGNORECASE):
            found_recipe_section = True
            recipe_content.append(line)
        elif found_recipe_section:
            # 비디오 정보 섹션이면 중단
            if re.search(r'구독|subscribe|좋아요|like|댓글|comment|링크|link|음악|music|equipment', line, re.IGNORECASE):
                break
            
            if len(line) > 3:
                recipe_content.append(line)
        # 재료 패턴 (숫자 + 단위)
        elif re.search(r'\d+\s*(?:개|g|ml|컵|큰술|작은술|마리|kg|L)', line, re.IGNORECASE):
            recipe_content.append(line)
    
    return '\n'.join(recipe_content)

async def extract_blog_content(url: str) -> UrlExtractionResponse:
    """블로그 콘텐츠 추출"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(str(url))
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # 제목 추출
            title_tag = soup.find('title') or soup.find('h1')
            title = title_tag.text.strip() if title_tag else ""
            
            # 콘텐츠 영역 선택자들
            content_selectors = [
                '.post-content', '.entry-content', '.article-content',
                '.content', '.post-body', 'article',
                '.se-main-container',  # 네이버 블로그
                '.article_body',       # 티스토리
            ]
            
            content_element = None
            for selector in content_selectors:
                content_element = soup.select_one(selector)
                if content_element:
                    break
            
            if not content_element:
                content_element = soup.find('body')
            
            if content_element:
                text = content_element.get_text()
                lines = text.split('\n')
                recipe_lines = []
                found_recipe = False
                
                for line in lines:
                    line = line.strip()
                    if not line:
                        continue
                        
                    # 레시피 키워드 검색
                    if re.search(r'재료|ingredient|만드는|조리|요리|레시피|recipe', line, re.IGNORECASE):
                        found_recipe = True
                        recipe_lines.append(line)
                    elif found_recipe and len(line) > 10:
                        recipe_lines.append(line)
                
                content = '\n'.join(recipe_lines) if recipe_lines else text[:1000]
                
                return UrlExtractionResponse(
                    success=True,
                    content=content,
                    title=title,
                    site_type="Blog"
                )
            
            return UrlExtractionResponse(
                success=False,
                error="콘텐츠를 찾을 수 없습니다."
            )
            
    except Exception as e:
        logger.error(f"블로그 콘텐츠 추출 오류: {e}")
        return UrlExtractionResponse(
            success=False,
            error=f"블로그 콘텐츠 추출 오류: {str(e)}"
        )

def is_youtube_url(url: str) -> bool:
    """YouTube URL 여부 확인"""
    return 'youtube.com' in url or 'youtu.be' in url

def is_blog_url(url: str) -> bool:
    """블로그 URL 여부 확인"""
    blog_patterns = ['blog', 'tistory', 'naver.com/PostView', 'velog.io']
    return any(pattern in url for pattern in blog_patterns)

@router.post("/extract", response_model=UrlExtractionResponse)
async def extract_content_from_url(
    request: UrlExtractionRequest,
    current_user: UserResponse = Depends(get_current_user)
):
    """
    URL에서 레시피 콘텐츠 추출
    
    - **url**: 추출할 URL (YouTube, 블로그 등)
    
    안전하게 서버에서 API 키를 관리하여 YouTube 콘텐츠를 추출합니다.
    """
    try:
        url_str = str(request.url)
        
        if is_youtube_url(url_str):
            return await extract_youtube_content(url_str)
        elif is_blog_url(url_str):
            return await extract_blog_content(url_str)
        else:
            # 일반 웹사이트 처리
            return await extract_blog_content(url_str)  # 동일한 로직 사용
            
    except Exception as e:
        logger.error(f"URL 콘텐츠 추출 오류: {e}")
        raise HTTPException(
            status_code=500, 
            detail=f"URL 콘텐츠 추출 중 오류가 발생했습니다: {str(e)}"
        )