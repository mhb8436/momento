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