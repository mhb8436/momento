# MOMENTO

> 엄마의 요리법을 음성으로 기록하고 AI로 정리하는 감성 요리 아카이빙 앱

## 🍳 프로젝트 소개

MOMENTO는 가족의 소중한 요리법을 음성으로 기록하고, AI가 이를 체계적인 레시피로 정리해주는 애플리케이션입니다.

### 주요 기능

- 🎤 음성으로 요리법 녹음
- 🤖 OpenAI Whisper를 통한 음성-텍스트 변환
- 📝 GPT를 활용한 레시피 자동 정리
- 👨‍👩‍👧‍👦 가족 간 레시피 공유
- 📱 어르신도 쉽게 사용할 수 있는 직관적 UI

## 🛠 기술 스택

**Backend (FastAPI)**

- Python 3.9+
- FastAPI + SQLAlchemy 2.0
- PostgreSQL
- OpenAI API (Whisper + GPT-3.5-turbo)
- JWT 인증

**Frontend (Flutter)**

- Flutter 3.13+
- Provider 상태관리
- Dio HTTP 클라이언트
- 커스텀 디자인 시스템

## 🚀 빠른 시작

### 1. 환경 설정

```bash
# 프로젝트 클론
git clone <repository-url>
cd momento

# 초기 설정 (자동)
./setup.sh
```

### 2. 환경변수 설정

`.env` 파일을 편집하여 다음을 설정:

```env
DATABASE_URL=postgresql://username:password@localhost:5432/momento
SECRET_KEY=your-secret-key-here
OPENAI_API_KEY=your-openai-api-key-here
```

### 3. 데이터베이스 생성

```bash
createdb momento
```

### 4. 서버 실행

```bash
./start_server.sh
```

### 5. Flutter 앱 실행

```bash
cd flutter_app
flutter pub get
flutter run
```

## 📚 API 문서

서버 실행 후 다음 URL에서 API 문서를 확인할 수 있습니다:

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 📁 프로젝트 구조

```
momento/
├── app/                    # FastAPI 백엔드
├── flutter_app/           # Flutter 프론트엔드
├── alembic/               # 데이터베이스 마이그레이션
├── requirements.txt       # Python 의존성
├── setup.sh              # 초기 설정 스크립트
├── start_server.sh       # 서버 실행 스크립트
└── CLAUDE.md             # 개발 가이드
```

## 🔧 개발 명령어

### Backend

```bash
# 서버 실행
./start_server.sh

# 마이그레이션 생성
alembic revision --autogenerate -m "description"

# 마이그레이션 적용
alembic upgrade head
```

### Frontend

```bash
cd flutter_app

# 의존성 설치
flutter pub get

# 코드 생성
flutter packages pub run build_runner build

# 앱 실행
flutter run
```

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/amazing-feature`)
3. Commit your Changes (`git commit -m 'Add some amazing-feature'`)
4. Push to the Branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 라이센스

This project is licensed under the MIT License.

## 📞 문의

프로젝트에 대한 문의사항이 있으시면 이슈를 등록해주세요.

## 추가기능-클로 추천

⏺ MOMENTO 앱에 추가할 만한 기능들을 추천드립니다:

#### 레시피 관리 & 검색

- 레시피 카테고리 분류 (한식, 중식, 반찬, 국물요리 등)
- 재료별 레시피 검색
- 즐겨찾기/북마크 기능
- 레시피 태그 시스템 (#간단요리, #손님요리 등)

#### 가족 공유 & 소셜

- 가족 그룹 생성 및 레시피 공유
- 레시피 댓글 및 평점 시스템
- 가족 구성원별 요리 히스토리
- 레시피 전수 알림 (할머니→엄마→딸)

#### 스마트 추천 & 알림

- 냉장고 재료 기반 레시피 추천
- 계절별/날씨별 요리 제안
- 요리 시간 타이머 및 알림
- 장보기 리스트 자동 생성

#### 멀티미디어 확장

- 요리 과정 사진/영상 첨부
- 완성 요리 사진 갤러리
- 음성 메모 추가 (조리 팁, 변형 레시피)
- 손글씨 레시피 이미지 OCR 변환

#### 개인화 & 건강

- 개인 맞춤 영양 정보 분석
- 알레르기/식이제한 필터링
- 칼로리 계산기
- 가족 구성원별 선호도 학습

## 추가기능 - 커서 GTP5

## 🍳 **요리 커뮤니티 핵심 기능**

### 1. **레시피 공유 시스템**

- **음성으로 레시피 설명 녹음** (핵심 차별화!)
- 사진과 함께 레시피 업로드
- 태그 시스템 (한식, 양식, 베이킹, 다이어트 등)
- 난이도, 소요시간, 인원수 표시
- 재료 목록과 단계별 설명

### 2. **소셜 상호작용**

- 댓글과 좋아요 시스템
- 팔로우/팔로워 기능
- 레시피 저장 (북마크)
- "이 레시피로 요리해봤어요" 인증 시스템

### 3. **음성 기반 커뮤니티**

- **음성 댓글** (요리 팁을 음성으로 공유)
- **음성으로 요리 팁 녹음**
- 실시간 음성 채팅 (요리 중 질문)
- 음성으로 레시피 리뷰

### 4. **관심사별 그룹**

- 베이킹 애호가 그룹
- 한식 전문가 그룹
- 다이어트 요리 그룹
- 초보자 도움 그룹

### 5. **실용적 커뮤니티**

- **요리 Q&A 섹션** (음성으로 질문/답변)
- 재료 교환/나눔 게시판
- 요리 도구 추천 및 리뷰
- 지역별 특산품 활용법 공유

### 6. **실시간 상호작용**

- **요리 라이브 스트리밍** (음성으로 실시간 설명)
- 전문 요리사와의 실시간 세션
- 요리 챌린지 참여
- 계절별 요리 이벤트

### 7. **협업 기능**

- 가족/친구와 레시피 공유
- 그룹 요리 계획
- 공동 쇼핑 리스트
- 요리 모임 일정 관리

### 8. **품질 관리**

- 레시피 검증 시스템
- 신고 기능
- 커뮤니티 가이드라인
- 전문가 인증 시스템

### 입력 방식 추천 (claude)

이미지 기반 입력

- 손글씨 레시피 사진: OCR로 할머니 레시피 노트 스캔
- 요리책/잡지 사진: 페이지 촬영 후 텍스트 추출
- 완성 요리 사진: 이미지 AI로 재료/조리법 역추론

텍스트 직접 입력

- 간단 메모 입력: 핵심만 적고 AI가 구조화
- 카톡/메신저 복붙: 엄마가 보내준 레시피 그대로 붙여넣기
- 음성 + 텍스트 혼합: 말로 설명하면서 부족한 부분 타이핑

외부 연동 및 가져오기

- 유튜브/블로그 URL: 링크만 입력하면 자동 추출
- 다른 앱 레시피 가져오기: 만개의레시피, 쿡패드 등에서 임포트
- QR코드 스캔: 제품 포장지의 조리법 QR 스캔

대화형 입력

- 챗봇 대화: "오늘 뭐 해먹지?" → 재료 말하면 레시피 제안
- 단계별 질문: AI가 묻고 사용자가 답하면서 레시피 완성
- 음성 + 실시간 피드백: 요리하면서 실시간으로 과정 기록

협업 입력

- 가족 공동 작성: 여러 명이 동시에 편집
- 전화 통화 녹음: 엄마와 통화하며 요리법 배울 때 자동 기록

어떤 방식이 MOMENTO의 "가족 요리 전수" 컨셉과 가장 잘 맞을 것 같으신가요?
