"""
관리자 알림 발송 라우터
SQLAdmin BaseView 문제 우회를 위한 직접 구현
"""
from fastapi import APIRouter, Request, Depends, Form, HTTPException
from fastapi.responses import HTMLResponse, JSONResponse
from starlette.templating import Jinja2Templates
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import Optional

from app.database import get_db, async_engine
from app.models.user import User
from app.services.notification_service import NotificationService

# 라우터 설정
router = APIRouter(prefix="/admin/notification", tags=["admin-notification"])
templates = Jinja2Templates(directory="templates")

# 간단한 관리자 권한 체크 (실제 환경에서는 더 엄격하게)
async def admin_required(request: Request):
    """관리자 권한 확인"""
    # SQLAdmin 세션에서 관리자 정보 확인
    admin_user_id = request.session.get("admin_user_id")
    if not admin_user_id:
        # 개발 중에는 임시로 우회
        return "temp_admin"  # TODO: 실제 인증 구현
    return admin_user_id

@router.get("/", response_class=HTMLResponse)
async def notification_send_form(
    request: Request,
    admin_user_id: str = Depends(admin_required),
    db: AsyncSession = Depends(get_db)
):
    """알림 발송 폼 표시"""
    # 활성 사용자 수 조회
    result = await db.execute(
        select(func.count(User.id)).where(User.is_active == True)
    )
    active_users_count = result.scalar() or 0
    
    # 템플릿 컨텍스트 준비
    context = {
        "request": request,
        "active_users_count": active_users_count,
        "action_url": "send"  # 상대 경로
    }
    
    return templates.TemplateResponse("admin/notification_send.html", context)

@router.get("/api/users-count", response_class=JSONResponse)
async def get_active_users_count(
    admin_user_id: str = Depends(admin_required),
    db: AsyncSession = Depends(get_db)
):
    """활성 사용자 수 조회 API"""
    result = await db.execute(
        select(func.count(User.id)).where(User.is_active == True)
    )
    active_users_count = result.scalar() or 0
    
    return {"count": active_users_count}

@router.get("/modal-demo", response_class=HTMLResponse)
async def notification_modal_demo(request: Request):
    """알림 발송 모달 데모 페이지"""
    return templates.TemplateResponse("admin/notification_modal_demo.html", {"request": request})

@router.post("/send", response_class=HTMLResponse)
async def send_notification(
    request: Request,
    admin_user_id: str = Depends(admin_required),
    title: str = Form(...),
    body: str = Form(...),
    target: str = Form(...),
    notification_type: str = Form(...),
    user_ids: Optional[str] = Form(None),
    db: AsyncSession = Depends(get_db)
):
    """알림 발송 처리"""
    
    # 입력 검증
    if not title or not body:
        context = {
            "request": request,
            "result_type": "error",
            "message": "제목과 내용을 입력해주세요.",
            "new_notification_url": "/admin/notification/",
            "dashboard_url": "/admin/"
        }
        return templates.TemplateResponse("admin/notification_result.html", context)
    
    # NotificationService 초기화
    notification_service = NotificationService(db)
    
    try:
        if target == "specific":
            # 특정 사용자들에게 발송
            if not user_ids:
                context = {
                    "request": request,
                    "result_type": "error", 
                    "message": "사용자 ID를 입력해주세요.",
                    "new_notification_url": "/admin/notification/",
                    "dashboard_url": "/admin/"
                }
                return templates.TemplateResponse("admin/notification_result.html", context)
            
            user_id_list = [uid.strip() for uid in user_ids.split(",") if uid.strip()]
            success_count = 0
            fail_count = 0
            
            for user_id in user_id_list:
                try:
                    await notification_service.send_notification(
                        user_id=user_id,
                        title=title,
                        body=body,
                        notification_type=notification_type
                    )
                    success_count += 1
                except Exception as e:
                    fail_count += 1
                    print(f"Failed to send to {user_id}: {e}")
            
            message = f"{success_count}명 발송 성공"
            if fail_count > 0:
                message += f", {fail_count}명 발송 실패"
        
        else:
            # 전체 발송
            result = await db.execute(select(User).where(User.is_active == True))
            users = result.scalars().all()
            
            success_count = 0
            for user in users:
                try:
                    await notification_service.send_notification(
                        user_id=str(user.id),
                        title=title,
                        body=body,
                        notification_type=notification_type
                    )
                    success_count += 1
                except Exception as e:
                    print(f"Failed to send to {user.id}: {e}")
            
            message = f"전체 {len(users)}명 중 {success_count}명에게 발송 완료"
        
        # 성공 결과 반환
        context = {
            "request": request,
            "result_type": "success",
            "message": message,
            "new_notification_url": "/admin/notification/",
            "dashboard_url": "/admin/"
        }
        
        return templates.TemplateResponse("admin/notification_result.html", context)
        
    except Exception as e:
        # 예외 처리
        context = {
            "request": request,
            "result_type": "error",
            "message": f"알림 발송 중 오류가 발생했습니다: {str(e)}",
            "new_notification_url": "/admin/notification/",
            "dashboard_url": "/admin/"
        }
        
        return templates.TemplateResponse("admin/notification_result.html", context)