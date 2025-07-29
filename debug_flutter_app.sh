#!/bin/bash

# MOMENTO Flutter 앱 디버그 실행 스크립트

echo "🐛 MOMENTO Flutter 앱을 디버그 모드로 실행합니다..."

# Flutter 경로 설정
FLUTTER_PATH="/Users/mhb8436/flutter/bin/flutter"

# flutter_app 디렉토리로 이동
cd /Users/mhb8436/Workspaces/momento/flutter_app

echo "📝 백엔드 서버 상태 확인..."
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ 백엔드 서버가 실행 중입니다 (http://localhost:8000)"
else
    echo "❌ 백엔드 서버가 실행되지 않고 있습니다!"
    echo "   다음 명령어로 백엔드 서버를 먼저 시작해주세요:"
    echo "   cd /Users/mhb8436/Workspaces/momento && ./start_server.sh"
    echo ""
    read -p "그래도 Flutter 앱을 실행하시겠습니까? (y/N): " continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "🔧 의존성 확인..."
$FLUTTER_PATH pub get

echo "🐛 Flutter 앱을 디버그 모드로 실행합니다..."
echo "📋 콘솔에서 다음과 같은 로그를 확인하세요:"
echo "   - 🔍 회원가입 시작: [이메일]"
echo "   - 🔍 AuthService signup API 호출: [이메일]"
echo "   - 🔍 API URL: [API 주소]"
echo "   - 🔍 API 응답: [응답 데이터]"
echo "   - ❌ 오류가 있다면 자세한 메시지가 표시됩니다"
echo ""

# Flutter 앱 실행
$FLUTTER_PATH run -d chrome --web-port=8080