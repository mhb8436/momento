#!/bin/bash

# MOMENTO Flutter 앱 실행 스크립트

echo "📱 MOMENTO Flutter 앱을 실행합니다..."

# Flutter 경로 설정
FLUTTER_PATH="/Users/mhb8436/flutter/bin/flutter"

# flutter_app 디렉토리로 이동
cd /Users/mhb8436/Workspaces/momento/flutter_app

# Flutter가 설치되어 있는지 확인
if [ ! -f "$FLUTTER_PATH" ]; then
    echo "❌ Flutter를 찾을 수 없습니다: $FLUTTER_PATH"
    echo "Flutter 설치 경로를 확인해주세요."
    exit 1
fi

echo "🔧 Flutter 버전 확인..."
$FLUTTER_PATH --version

echo "📦 의존성 설치..."
$FLUTTER_PATH pub get

echo "🔨 코드 생성..."
$FLUTTER_PATH packages pub run build_runner build

echo "📱 사용 가능한 디바이스 확인..."
$FLUTTER_PATH devices

echo ""
echo "🚀 앱 실행 옵션:"
echo "1. 웹 브라우저 (Chrome)에서 실행"
echo "2. macOS 데스크톱 앱으로 실행 (Xcode 필요)"
echo "3. iOS 시뮬레이터에서 실행 (시뮬레이터 필요)"
echo ""

# 사용자 선택 받기
read -p "실행할 플랫폼을 선택하세요 (1-3): " choice

case $choice in
    1)
        echo "🌐 Chrome 브라우저에서 실행합니다..."
        $FLUTTER_PATH run -d chrome --web-port=8080
        ;;
    2)
        echo "🖥️  macOS 데스크톱 앱으로 실행합니다..."
        $FLUTTER_PATH run -d macos
        ;;
    3)
        echo "📱 iOS 시뮬레이터에서 실행합니다..."
        $FLUTTER_PATH run -d ios
        ;;
    *)
        echo "❌ 잘못된 선택입니다. 기본값으로 Chrome에서 실행합니다..."
        $FLUTTER_PATH run -d chrome --web-port=8080
        ;;
esac