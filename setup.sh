#!/bin/bash

# MOMENTO 프로젝트 초기 설정 스크립트

echo "🛠️  MOMENTO 프로젝트 초기 설정을 시작합니다..."

# Python 버전 확인
echo "🐍 Python 버전 확인..."
python3 --version

# 가상환경 생성
if [ ! -d "venv" ]; then
    echo "📦 Python 가상환경을 생성합니다..."
    python3 -m venv venv
fi

# 가상환경 활성화
echo "🔧 가상환경을 활성화합니다..."
source venv/bin/activate

# 의존성 설치
echo "📚 의존성을 설치합니다..."
pip install --upgrade pip
pip install -r requirements.txt

# .env 파일 생성
if [ ! -f .env ]; then
    echo "⚙️  환경변수 파일을 생성합니다..."
    cp .env.example .env
    echo "❗ .env 파일을 편집하여 데이터베이스 정보와 API 키를 설정해주세요."
fi

# PostgreSQL 확인 및 설정
echo "🐘 PostgreSQL 상태 확인..."
if command -v psql >/dev/null 2>&1; then
    echo "✅ PostgreSQL이 설치되어 있습니다."
    
    # PostgreSQL 서비스 시작
    if ! pgrep -x "postgres" >/dev/null; then
        echo "🔧 PostgreSQL 서비스를 시작합니다..."
        brew services start postgresql 2>/dev/null || {
            echo "⚠️  PostgreSQL 서비스를 수동으로 시작해주세요:"
            echo "brew services start postgresql"
        }
        sleep 2
    fi
    
    # 데이터베이스 설정 실행
    echo "📊 데이터베이스를 설정합니다..."
    ./setup_db.sh
else
    echo "❌ PostgreSQL이 설치되지 않았습니다."
    echo "다음 명령어로 설치해주세요:"
    echo "brew install postgresql"
    echo "brew services start postgresql"
fi

# 설정 완료
echo ""
echo "🎉 초기 설정이 완료되었습니다!"
echo ""
echo "다음 단계:"
echo "1. .env 파일을 편집하여 OpenAI API 키를 설정하세요"
echo "   OPENAI_API_KEY=your-openai-api-key-here"
echo "2. 서버를 시작하세요:"
echo "   ./start_server.sh"
echo ""