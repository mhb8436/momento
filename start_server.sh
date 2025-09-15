#!/bin/bash

# MOMENTO 서버 시작 스크립트

echo "🚀 MOMENTO 서버를 시작합니다..."

# 가상환경 활성화
if [[ "$VIRTUAL_ENV" == "" ]]; then
    if [ -f "venv/bin/activate" ]; then
        echo "🔧 가상환경을 활성화합니다..."
        source venv/bin/activate
    else
        echo "❌ 가상환경이 없습니다. 먼저 setup.sh를 실행해주세요."
        exit 1
    fi
else
    echo "✅ 가상환경이 이미 활성화되어 있습니다."
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

# 마이그레이션이 없으면 생성
if [ ! -f alembic/versions/*.py ] 2>/dev/null; then
    echo "🔧 초기 마이그레이션을 생성합니다..."
    alembic revision --autogenerate -m "Initial migration"
fi

echo "🔧 최신 마이그레이션 적용..."
alembic upgrade head

# 서버 시작
echo "✅ 서버를 시작합니다..."
echo "📝 API 문서: http://localhost:8000/docs"
echo "🔧 ReDoc: http://localhost:8000/redoc"
echo "❤️  헬스체크: http://localhost:8000/health"
echo ""

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000