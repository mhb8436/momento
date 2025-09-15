from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.sessions import SessionMiddleware
from app.routers import auth, audio, recipes, uploads, inquiry, notifications, url_extract, community, community_additional, credits, admin_notification
from app.admin import setup_admin
from app.config import settings

app = FastAPI(
    title="MOMENTO API",
    description="엄마의 요리법을 음성으로 기록하고 AI로 정리하는 감성 요리 아카이빙 앱",
    version="1.0.0"
)

# Session middleware for admin authentication
app.add_middleware(SessionMiddleware, secret_key=settings.secret_key)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 개발 중에만 사용, 프로덕션에서는 특정 도메인 지정
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["authentication"])
app.include_router(audio.router, prefix="/audio", tags=["audio"])
app.include_router(recipes.router, prefix="/recipes", tags=["recipes"])
app.include_router(uploads.router)
app.include_router(inquiry.router, prefix="/inquiries", tags=["inquiries"])
app.include_router(notifications.router)
app.include_router(url_extract.router)
app.include_router(community.router)
app.include_router(community_additional.router)
app.include_router(credits.router, prefix="/credits", tags=["credits"])
app.include_router(admin_notification.router)

# Setup admin interface
setup_admin(app)


@app.get("/")
async def root():
    return {"message": "MOMENTO API Server", "version": "1.0.0"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}