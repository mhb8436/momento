# YouTube API 설정 가이드

YouTube에서 레시피를 추출하기 위해서는 YouTube Data API v3 키가 필요합니다.

## API 키 발급 단계

### 1. Google Cloud Console 접속
- https://console.cloud.google.com/ 에 접속
- Google 계정으로 로그인

### 2. 프로젝트 생성 또는 선택
- 새 프로젝트 생성 또는 기존 프로젝트 선택
- 프로젝트 이름: `momento-youtube-api` (예시)

### 3. YouTube Data API v3 활성화
- **API 및 서비스** → **라이브러리** 메뉴 이동
- "YouTube Data API v3" 검색
- **사용** 버튼 클릭하여 API 활성화

### 4. API 키 생성
- **API 및 서비스** → **사용자 인증 정보** 메뉴 이동
- **사용자 인증 정보 만들기** → **API 키** 선택
- API 키가 생성됨 (예: `AIzaSyD1234567890abcdefghijklmnopqr`)

### 5. API 키 제한 설정 (보안)
- 생성된 API 키 클릭
- **API 제한사항**에서 "YouTube Data API v3"만 선택
- **애플리케이션 제한사항**에서 적절한 제한 설정

## 코드에 API 키 적용

### 방법 1: 직접 코드 수정
```dart
// lib/services/youtube/youtube_api_service.dart
static const String _apiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

### 방법 2: 환경변수 사용 (권장)
```dart
// pubspec.yaml에 flutter_dotenv 추가
dependencies:
  flutter_dotenv: ^5.1.0

// .env 파일 생성
YOUTUBE_API_KEY=your_actual_api_key_here

// 코드에서 사용
static String get _apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
```

## API 할당량 및 비용

- **무료 할당량**: 하루 10,000 units
- **일반적인 사용량**:
  - 비디오 세부정보 조회: 1 unit
  - 자막 목록 조회: 50 units
- **비용**: 할당량 초과시 100만 units당 $1

## 테스트 방법

1. API 키를 설정한 후 앱 재시작
2. URL 입력 화면에서 YouTube 링크 입력
   - 예: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
3. "추출하기" 버튼 클릭
4. 비디오 제목, 채널명, 설명란 내용이 표시되면 성공

## 주의사항

⚠️ **API 키 보안**
- API 키를 GitHub에 커밋하지 마세요
- `.env` 파일을 `.gitignore`에 추가하세요
- 프로덕션 환경에서는 서버를 통해 API 호출하는 것을 권장

⚠️ **자막 추출 제한**
- 자막 내용을 실제로 다운로드하려면 OAuth 2.0 인증 필요
- 현재 구현은 자막 목록만 조회 가능

## 문제 해결

### "API key not valid" 오류
- API 키가 올바르게 설정되었는지 확인
- YouTube Data API v3가 활성화되었는지 확인
- API 키 제한 설정 확인

### "Quota exceeded" 오류  
- 일일 할당량(10,000 units) 초과
- 다음 날까지 대기 또는 할당량 증가 요청

### "Video not found" 오류
- 비디오가 비공개 또는 삭제되었을 가능성
- 올바른 YouTube URL인지 확인