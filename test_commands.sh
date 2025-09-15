#!/bin/bash

# MOMENTO 앱 크레딧 시스템 테스트 스크립트
# 개발 환경에서 즉시 실행 가능한 테스트들

echo "🧪 MOMENTO 크레딧 시스템 테스트 시작"

# 현재 위치 확인
cd flutter_app

echo "\n📋 1. Flutter 의존성 확인"
flutter doctor
flutter pub get

echo "\n🔍 2. Dart 코드 분석"
dart analyze lib/

echo "\n📱 3. 단위 테스트 실행"
# 먼저 mockito 코드 생성
flutter packages pub run build_runner build

# 크레딧 시스템 단위 테스트
if [ -f "test/credit_test.dart" ]; then
    flutter test test/credit_test.dart
else
    echo "⚠️  단위 테스트 파일이 없습니다. test/credit_test.dart 파일을 생성해주세요."
fi

echo "\n🏗️  4. 빌드 테스트 (Android)"
flutter build apk --debug --verbose

echo "\n🍎 5. 빌드 테스트 (iOS)"
flutter build ios --debug --no-codesign --verbose

echo "\n📊 6. 코드 커버리지 분석"
flutter test --coverage
if [ -f "coverage/lcov.info" ]; then
    genhtml coverage/lcov.info -o coverage/html
    echo "✅ 커버리지 리포트: coverage/html/index.html"
fi

echo "\n🔧 7. 크레딧 시스템 구성 요소 확인"
echo "📁 Models:"
ls -la lib/models/credit*
echo "📁 Services:"
ls -la lib/services/credit/
echo "📁 Providers:"
ls -la lib/providers/credit*
echo "📁 Screens:"
ls -la lib/screens/credit/
echo "📁 Widgets:"
ls -la lib/widgets/credit/

echo "\n📱 8. 디바이스 연결 확인"
flutter devices

echo "\n⚡ 9. 핫 리로드 테스트 (시뮬레이터/에뮬레이터에서)"
echo "다음 명령어로 앱 실행 후 코드 변경사항 확인:"
echo "flutter run"

echo "\n🔍 10. 인앱 결제 관련 설정 확인"
echo "📄 Android Manifest:"
grep -n "BILLING" android/app/src/main/AndroidManifest.xml || echo "⚠️  BILLING 권한이 없습니다."

echo "📄 iOS Info.plist:"
grep -n "SKStorekit" ios/Runner/Info.plist || echo "ℹ️  StoreKit 설정을 확인해주세요."

echo "📄 Pubspec 의존성:"
grep -A 5 -B 5 "in_app_purchase" pubspec.yaml

echo "\n✅ 테스트 스크립트 완료!"
echo "📋 다음 단계:"
echo "1. 실제 디바이스 연결 후: flutter run"
echo "2. 크레딧 스토어 화면 테스트"
echo "3. 구매 플로우 시뮬레이션"
echo "4. 서버 연결 테스트"

# 간단한 연결 테스트
echo "\n🌐 11. 서버 연결 테스트"
if command -v curl &> /dev/null; then
    echo "서버 상태 확인 중..."
    curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health || echo "⚠️  서버가 실행되지 않았습니다."
else
    echo "⚠️  curl이 설치되지 않았습니다."
fi