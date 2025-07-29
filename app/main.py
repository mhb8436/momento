from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, audio, recipes

app = FastAPI(
    title="MOMENTO API",
    description="엄마의 요리법을 음성으로 기록하고 AI로 정리하는 감성 요리 아카이빙 앱",
    version="1.0.0"
)

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


@app.get("/")
async def root():
    return {"message": "MOMENTO API Server", "version": "1.0.0"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}