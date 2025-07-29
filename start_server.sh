#!/bin/bash

# MOMENTO 서버 시작 스크립트

echo "🚀 MOMENTO 서버를 시작합니다..."

# 가상환경 활성화 확인
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo "⚠️  가상환경이 활성화되지 않았습니다."
    echo "다음 명령어로 가상환경을 활성화해주세요:"
    echo "source venv/bin/activate"
    exit 1
fi

# .env 파일 존재 확인
if [ ! -f .env ]; then
    echo "❌ .env 파일이 없습니다."
    echo "cp .env.example .env 를 실행하고 환경변수를 설정해주세요."
    exit 1
fi

# 데이터베이스 마이그레이션 확인
echo "📊 데이터베이스 마이그레이션 상태 확인..."
alembic current

echo "🔧 최신 마이그레이션 적용..."
alembic upgrade head

# 서버 시작
echo "✅ 서버를 시작합니다..."
echo "📝 API 문서: http://localhost:8000/docs"
echo "🔧 ReDoc: http://localhost:8000/redoc"
echo "❤️  헬스체크: http://localhost:8000/health"
echo ""

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000