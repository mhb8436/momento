from sqladmin import Admin, ModelView, BaseView, expose
from sqladmin.authentication import AuthenticationBackend
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_
from fastapi import Request
from starlette.responses import RedirectResponse, HTMLResponse
from starlette.requests import Request as StarletteRequest
from starlette.templating import Jinja2Templates
from typing import Optional, List, Dict, Any
from datetime import datetime
import uuid
import json

from app.models.user import User, UserRole
from app.models.recipe import Recipe
from app.models.inquiry import Inquiry
from app.models.notification import NotificationLog
from app.models.credit import UserCredit, PaymentHistory, APIUsageLog, PackageType, PaymentStatus, PaymentPlatform
from app.utils.security import verify_password
from app.database import async_engine
from app.config import settings

# Jinja2 템플릿 설정
templates = Jinja2Templates(directory="templates")


class AdminAuth(AuthenticationBackend):
    """SQLAdmin 인증 백엔드"""
    
    async def login(self, request: Request) -> bool:
        """관리자 로그인 처리"""
        try:
            form = await request.form()
            email = str(form.get("username", ""))
            password = str(form.get("password", ""))
            
            print(f"Admin login attempt: email={email}, password_length={len(password)}")
            
            if not email or not password:
                print("Missing email or password")
                return False
            
            # 데이터베이스에서 관리자 계정 확인
            async with AsyncSession(async_engine) as session:
                result = await session.execute(
                    select(User).where(
                        User.email == email,
                        User.is_admin == True,
                        User.is_active == True
                    )
                )
                admin_user = result.scalar_one_or_none()
                
                if not admin_user:
                    print(f"Admin user not found for email: {email}")
                    return False
                
                print(f"Found admin user: {admin_user.email}, role: {admin_user.role}")
                
                if verify_password(password, admin_user.password_hash):
                    # 세션에 관리자 정보 저장
                    request.session["admin_user_id"] = str(admin_user.id)
                    request.session["admin_email"] = admin_user.email
                    request.session["admin_role"] = admin_user.role.value
                    print("Login successful")
                    return True
                else:
                    print("Password verification failed")
                    return False
        
        except Exception as e:
            print(f"Login error: {e}")
            return False
    
    async def logout(self, request: Request) -> bool:
        """관리자 로그아웃 처리"""
        request.session.clear()
        return True
    
    async def authenticate(self, request: Request) -> bool:
        """관리자 인증 확인"""
        return "admin_user_id" in request.session


# 커스텀 ModelView들
class UserAdmin(ModelView, model=User):
    """사용자 관리"""
    name = "사용자 관리"
    name_plural = "사용자들"
    icon = "fa-solid fa-users"
    
    column_list = [User.id, User.email, User.full_name, User.role, User.is_active, User.created_at]
    column_searchable_list = [User.email, User.full_name]
    column_sortable_list = [User.email, User.full_name, User.role, User.created_at]
    column_default_sort = [(User.created_at, True)]  # 최신순
    
    # 관리자만 편집 가능한 필드
    form_columns = [User.email, User.full_name, User.role, User.is_admin, User.is_active]
    
    # 표시 형식 설정
    column_formatters = {
        User.role: lambda m, a: {
            UserRole.USER: "일반 사용자",
            UserRole.ADMIN: "관리자", 
            UserRole.SUPER_ADMIN: "슈퍼 관리자"
        }.get(a, a),
        User.is_active: lambda m, a: "활성" if a else "비활성",
        User.created_at: lambda m, a: a.strftime("%Y-%m-%d %H:%M") if a and hasattr(a, 'strftime') else str(a) if a else ""
    }


class RecipeAdmin(ModelView, model=Recipe):
    """레시피 관리"""
    name = "레시피 관리"
    name_plural = "레시피들"
    icon = "fa-solid fa-utensils"
    
    column_list = [Recipe.id, Recipe.title, Recipe.user_id, Recipe.visibility, Recipe.created_at]
    column_searchable_list = [Recipe.title]
    column_sortable_list = [Recipe.title, Recipe.created_at, Recipe.visibility]
    column_default_sort = [(Recipe.created_at, True)]
    
    form_columns = [Recipe.title, Recipe.description, Recipe.ingredients, Recipe.steps, Recipe.tips, Recipe.visibility]
    
    # column_formatters 임시 비활성화 - 기본 표시 사용
    # column_formatters = {}


class InquiryAdmin(ModelView, model=Inquiry):
    """문의사항 관리"""
    name = "문의사항 관리" 
    name_plural = "문의사항들"
    icon = "fa-solid fa-question-circle"
    
    column_list = [
        Inquiry.id, Inquiry.title, Inquiry.category, Inquiry.status, 
        Inquiry.user_id, Inquiry.created_at, Inquiry.admin_response_at
    ]
    column_searchable_list = [Inquiry.title, Inquiry.content]
    column_sortable_list = [Inquiry.created_at, Inquiry.status, Inquiry.category]
    column_default_sort = [(Inquiry.created_at, True)]
    
    # 관리자가 답변할 수 있는 필드들
    form_columns = [
        Inquiry.title, Inquiry.content, Inquiry.category, Inquiry.status,
        Inquiry.admin_response
    ]
    
    # 읽기 전용 필드들
    form_widget_args = {
        "title": {"readonly": True},
        "content": {"readonly": True}, 
        "category": {"readonly": True}
    }
    
    # column_formatters 임시 비활성화 - 기본 표시 사용
    # column_formatters = {}
    
    async def on_model_change(self, data: Dict, model: Any, is_created: bool, request: Request) -> None:
        """모델 변경 시 호출 - 답변 추가 시 알림 발송"""
        # 답변이 추가되고 상태가 변경되었는지 확인
        if not is_created and data.get("admin_response") and data.get("status") in ["answered", "closed"]:
            # 기존 데이터와 비교하여 새로운 답변인지 확인
            async with AsyncSession(async_engine) as db:
                result = await db.execute(
                    select(Inquiry).where(Inquiry.id == model.id)
                )
                existing_inquiry = result.scalar_one_or_none()
                
                # 이전에 답변이 없었거나 답변이 변경된 경우
                if existing_inquiry and (not existing_inquiry.admin_response or 
                                       existing_inquiry.admin_response != data.get("admin_response")):
                    # 알림 발송
                    try:
                        from app.services.notification_service import NotificationService
                        from app.database import AsyncSessionLocal
                        
                        async with AsyncSessionLocal() as notification_db:
                            notification_service = NotificationService(notification_db)
                            
                            # 문의 제목으로 알림 제목 생성
                            title = f"문의사항 답변: {existing_inquiry.title[:30]}..."
                            body = "문의하신 내용에 대한 답변이 등록되었습니다. 앱에서 확인해주세요."
                            
                            await notification_service.send_notification(
                                user_id=str(existing_inquiry.user_id),
                                title=title,
                                body=body,
                                notification_type="inquiry_answer"
                            )
                    except Exception as e:
                        # 알림 발송 실패해도 답변 저장은 진행
                        print(f"알림 발송 실패: {e}")


class NotificationAdmin(ModelView, model=NotificationLog):
    """알림 로그 관리"""
    name = "알림 관리"
    name_plural = "알림 관리"
    icon = "fa-solid fa-bell"
    
    column_list = [
        NotificationLog.id, NotificationLog.user_id, NotificationLog.title,
        NotificationLog.notification_type, NotificationLog.is_read, NotificationLog.sent_at
    ]
    column_searchable_list = [NotificationLog.title, NotificationLog.body]
    column_sortable_list = [NotificationLog.sent_at, NotificationLog.is_read, NotificationLog.notification_type]
    column_default_sort = [(NotificationLog.sent_at, True)]
    
    # 알림 발송을 위한 생성 기능 활성화
    can_create = True
    can_edit = False  # 발송된 알림은 편집 불가
    can_delete = False  # 로그 삭제 불가
    
    # 생성 폼에 표시할 필드들 - user_id 제외 (자동 처리)
    form_columns = [
        NotificationLog.title,
        NotificationLog.body, 
        NotificationLog.notification_type
    ]
    
    # 폼 위젯 설정
    form_widget_args = {
        "title": {"placeholder": "예: 새로운 기능이 추가되었습니다!"},
        "body": {"placeholder": "예: 안녕하세요! 새로운 기능이 추가되어 알려드립니다. 자세한 내용은 앱에서 확인해주세요.", "rows": 4}
    }
    
    async def on_model_change(self, data: Dict, model: Any, is_created: bool, request: Request) -> None:
        """새 알림 생성 시 실제 알림 발송 처리"""
        if is_created:
            from app.services.notification_service import NotificationService
            from app.database import AsyncSessionLocal
            
            try:
                title = data.get("title", "")
                body = data.get("body", "")
                notification_type = data.get("notification_type", "general")
                
                if not title or not body:
                    print("❌ 알림 제목과 내용이 필요합니다")
                    return
                
                async with AsyncSessionLocal() as db:
                    notification_service = NotificationService(db)
                    
                    # 모든 활성 사용자에게 발송
                    result = await db.execute(select(User).where(User.is_active == True))
                    users = result.scalars().all()
                    
                    if users:
                        # 첫 번째 사용자를 현재 모델의 user_id로 설정 (DB 제약 조건 충족)
                        first_user = users[0]
                        model.user_id = first_user.id
                        
                        # 모든 사용자에게 실제 알림 발송
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
                                print(f"❌ 사용자 {user.id} 알림 발송 실패: {e}")
                        
                        print(f"✅ 전체 {len(users)}명 중 {success_count}명에게 알림 발송 완료")
                    else:
                        print("❌ 활성 사용자가 없습니다")
                        # 활성 사용자가 없으면 관리자로 설정
                        admin_result = await db.execute(
                            select(User).where(User.is_admin == True).limit(1)
                        )
                        admin_user = admin_result.scalar_one_or_none()
                        if admin_user:
                            model.user_id = admin_user.id
                            print(f"🔄 관리자를 기본 사용자로 설정: {admin_user.email}")
                        else:
                            raise Exception("사용 가능한 사용자가 없습니다")
                        
            except Exception as e:
                print(f"❌ 알림 발송 중 오류 발생: {e}")
                # 에러 발생 시에도 기본 user_id 설정하여 저장이 가능하도록
                from app.database import AsyncSessionLocal
                async with AsyncSessionLocal() as db:
                    admin_result = await db.execute(
                        select(User).where(User.is_admin == True).limit(1)
                    )
                    admin_user = admin_result.scalar_one_or_none()
                    if admin_user:
                        model.user_id = admin_user.id
    
    # 추가 기능을 위한 별도 알림 발송 페이지 (고급 기능용)
    @expose("/advanced", methods=["GET"])
    async def advanced_send(self, request: Request):
        """고급 알림 발송 페이지로 리다이렉트 (모달, 다중 선택 등)"""
        return RedirectResponse(url="/admin/notification/", status_code=302)
    
    # column_formatters 임시 비활성화 - 기본 표시 사용
    # column_formatters = {}


class UserCreditAdmin(ModelView, model=UserCredit):
    """사용자 크레딧 관리"""
    name = "크레딧 관리"
    name_plural = "사용자 크레딧"
    icon = "fa-solid fa-coins"
    
    column_list = [
        UserCredit.user_id, UserCredit.balance, UserCredit.free_daily_used,
        UserCredit.total_purchased, UserCredit.total_used, UserCredit.has_auto_recharge,
        UserCredit.auto_recharge_expires_at, UserCredit.updated_at
    ]
    # UUID 검색을 위해 제거 (수동으로 처리)
    column_searchable_list = []
    column_sortable_list = [
        UserCredit.balance, UserCredit.total_purchased, UserCredit.total_used, 
        UserCredit.updated_at, UserCredit.auto_recharge_expires_at
    ]
    column_default_sort = [(UserCredit.updated_at, True)]
    
    # 편집 가능한 필드들
    form_columns = [
        UserCredit.balance, UserCredit.free_daily_used, 
        UserCredit.has_auto_recharge, UserCredit.auto_recharge_expires_at
    ]
    
    # column_formatters 임시 비활성화 - 기본 표시 사용
    # column_formatters = {}


class PaymentHistoryAdmin(ModelView, model=PaymentHistory):
    """결제 내역 관리"""
    name = "결제 내역"
    name_plural = "결제 내역들"
    icon = "fa-solid fa-credit-card"
    
    column_list = [
        PaymentHistory.id, PaymentHistory.user_id, PaymentHistory.package_type,
        PaymentHistory.credits_amount, PaymentHistory.price_paid, PaymentHistory.platform,
        PaymentHistory.status, PaymentHistory.created_at
    ]
    column_searchable_list = [PaymentHistory.transaction_id]
    column_sortable_list = [
        PaymentHistory.created_at, PaymentHistory.price_paid, 
        PaymentHistory.status, PaymentHistory.platform
    ]
    column_default_sort = [(PaymentHistory.created_at, True)]
    
    # 상태만 수정 가능 (환불 처리 등)
    form_columns = [PaymentHistory.status]
    
    # 읽기 전용 필드들
    column_details_list = [
        PaymentHistory.id, PaymentHistory.user_id, PaymentHistory.package_type,
        PaymentHistory.credits_amount, PaymentHistory.price_paid, PaymentHistory.platform,
        PaymentHistory.transaction_id, PaymentHistory.status, PaymentHistory.created_at,
        PaymentHistory.verified_at
    ]
    
    # column_formatters 임시 비활성화 - 기본 표시 사용
    # column_formatters = {}


class APIUsageLogAdmin(ModelView, model=APIUsageLog):
    """API 사용 로그"""
    name = "API 사용 로그"
    name_plural = "API 사용 로그들"
    icon = "fa-solid fa-chart-line"
    
    column_list = [
        APIUsageLog.id, APIUsageLog.user_id, APIUsageLog.api_type,
        APIUsageLog.credits_used, APIUsageLog.is_free_tier, APIUsageLog.created_at
    ]
    column_searchable_list = []
    column_sortable_list = [APIUsageLog.created_at, APIUsageLog.api_type, APIUsageLog.is_free_tier]
    column_default_sort = [(APIUsageLog.created_at, True)]
    
    # 읽기 전용 (로그이므로)
    can_create = False
    can_edit = False
    can_delete = False
    
    # column_formatters 임시 비활성화 - 기본 표시 사용
    # column_formatters = {}


# NotificationSendView는 별도 FastAPI 라우터로 구현됨
# 경로: /admin/notification/ (admin_notification.py 파일 참조)


def setup_admin(app):
    """FastAPI 앱에 SQLAdmin 설정"""
    
    # Admin 인스턴스 생성 (인증 재활성화)
    admin = Admin(
        app=app,
        engine=async_engine,
        authentication_backend=AdminAuth(secret_key=settings.secret_key),
        title="MOMENTO 관리자",
        templates_dir="templates"  # 템플릿 디렉토리 명시적 설정
    )
    
    
    # ModelView 등록 (문제가 있는 뷰들 임시 비활성화)
    try:
        admin.add_view(UserAdmin)
        print("✅ UserAdmin view added successfully")
    except Exception as e:
        print(f"❌ Failed to add UserAdmin: {e}")
    
    try:
        admin.add_view(UserCreditAdmin)
        print("✅ UserCreditAdmin view added successfully")
    except Exception as e:
        print(f"❌ Failed to add UserCreditAdmin: {e}")
    
    # 점진적으로 뷰 추가
    try:
        admin.add_view(RecipeAdmin)
        print("✅ RecipeAdmin view added successfully")
    except Exception as e:
        print(f"❌ Failed to add RecipeAdmin: {e}")
    
    # 점진적으로 뷰 추가 - InquiryAdmin
    try:
        admin.add_view(InquiryAdmin)
        print("✅ InquiryAdmin view added successfully")
    except Exception as e:
        print(f"❌ Failed to add InquiryAdmin: {e}")
    
    # 점진적으로 뷰 추가 - PaymentHistoryAdmin
    try:
        admin.add_view(PaymentHistoryAdmin)
        print("✅ PaymentHistoryAdmin view added successfully")
    except Exception as e:
        print(f"❌ Failed to add PaymentHistoryAdmin: {e}")
    
    # 점진적으로 뷰 추가 - APIUsageLogAdmin
    try:
        admin.add_view(APIUsageLogAdmin)
        print("✅ APIUsageLogAdmin view added successfully")
    except Exception as e:
        print(f"❌ Failed to add APIUsageLogAdmin: {e}")
    
    # 점진적으로 뷰 추가 - NotificationAdmin
    try:
        admin.add_view(NotificationAdmin)
        print("✅ NotificationAdmin view added successfully")
    except Exception as e:
        print(f"❌ Failed to add NotificationAdmin: {e}")
    
    # 알림 발송 기능은 별도 FastAPI 라우터로 구현됨 (/admin/notification/)
    print("📨 알림 발송 기능은 /admin/notification/ 경로에서 별도 구현됨")
    
    print("📋 관리자 패널 뷰 등록 완료!")
    
    return admin