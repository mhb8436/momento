# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MOMENTO is an emotional cooking archiving app that records family cooking recipes through voice and stories, allowing warm sharing among family members. The app focuses on capturing mom's cooking methods through voice recordings and converting them into organized recipes using AI.

**Key Features:**
- Voice recording of cooking instructions
- STT (Speech-to-Text) conversion using OpenAI Whisper
- Recipe organization and summarization using GPT
- Family sharing with personalized recommendations
- Senior-friendly interface with automatic suggestions

## Tech Stack

**Frontend:** Flutter
- Provider pattern for state management
- Custom UI components with Korean design system
- Audio recording and file upload functionality
- JWT-based authentication
- API communication with Dio HTTP client

**Backend:** FastAPI (Python)
- REST API server with JWT authentication
- OpenAI Whisper API integration for STT
- GPT-3.5-turbo integration for recipe summarization
- Audio file storage and processing
- SQLAlchemy 2.0 with async support

**Infrastructure:**
- AWS EC2 + Docker for deployment
- PostgreSQL database
- S3 or local storage for audio files

## Development Commands

### Quick Setup
```bash
# Run setup script (recommended for first time)
./setup.sh

# Or manual setup:
python -m venv venv
source venv/bin/activate  # Linux/macOS
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your OpenAI API key

# PostgreSQL setup
brew install postgresql  # if not installed
brew services start postgresql
./setup_db.sh  # Creates user and database automatically
```

### Development Server
```bash
# Quick start (recommended)
./start_server.sh

# Or manual start:
source venv/bin/activate  # Activate virtual environment first
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Alternative with custom port
uvicorn app.main:app --reload --port 8080
```

### Database Operations
```bash
# Create new migration
alembic revision --autogenerate -m "Description of changes"

# Apply migrations
alembic upgrade head

# Rollback to previous migration
alembic downgrade -1

# Check current migration status
alembic current
```

### Flutter Development
```bash
# Navigate to Flutter app directory
cd flutter_app

# Install dependencies
flutter pub get

# Generate code (for JSON serialization)
flutter packages pub run build_runner build

# Run app (iOS Simulator)
flutter run

# Run app (Android Emulator)
flutter run

# Run app on specific device
flutter run -d <device_id>

# Build for release
flutter build apk --release
flutter build ios --release
```

### Testing API
```bash
# API documentation available at:
# http://localhost:8000/docs (Swagger UI)
# http://localhost:8000/redoc (ReDoc)
```

## API Architecture

### Authentication Endpoints
```
POST /auth/signup    # User registration
POST /auth/login     # JWT token issuance
GET  /auth/me        # Current user info
```

### Audio Processing Endpoints
```
POST /audio/upload   # Upload recorded audio file
POST /audio/process  # STT + GPT processing
GET  /audio/:id/transcript # Get transcription result
```

### Recipe Management Endpoints
```
POST /recipes        # Save processed recipe
GET  /recipes        # List user recipes
GET  /recipes/:id    # Recipe details
DELETE /recipes/:id  # Delete recipe
PUT  /recipes/:id    # Update recipe
```

## Database Schema

### Core Tables
- `users`: User authentication and profile data
- `audio_files`: Uploaded audio recordings and transcripts
- `recipes`: Organized recipe data with ingredients, steps, and tips
- Relations: User → Audio Files → Recipes

## Key Processing Flow

1. User records cooking instructions via Flutter app
2. Audio uploaded to FastAPI server via `/audio/upload`
3. Server processes audio through Whisper API (STT)
4. Transcribed text sent to GPT for recipe organization
5. Structured recipe (ingredients, steps, tips) saved to database
6. Recipe available for viewing and family sharing

## AI Integration

**Whisper API:** Converts Korean voice recordings to text
**GPT-3.5-turbo:** Structures raw cooking instructions into:
- Ingredient list with quantities
- Step-by-step cooking instructions  
- Tips and variations
- Suitable title generation

## Flutter Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/
│   │   ├── app_config.dart         # App configuration constants
│   │   └── theme.dart              # UI theme and colors
│   ├── models/                     # Data models with JSON serialization
│   │   ├── user.dart
│   │   ├── audio_file.dart
│   │   └── recipe.dart
│   ├── providers/                  # State management (Provider pattern)
│   │   ├── auth_provider.dart
│   │   ├── audio_provider.dart
│   │   └── recipe_provider.dart
│   ├── services/                   # Business logic and API calls
│   │   ├── api/
│   │   │   ├── api_service.dart    # HTTP client wrapper
│   │   │   └── auth_service.dart   # Authentication API calls
│   │   ├── storage/
│   │   │   └── local_storage_service.dart # SharedPreferences wrapper
│   │   └── audio/                  # Audio recording services
│   ├── screens/                    # UI screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── audio/                  # Audio recording screens
│   │   └── recipe/                 # Recipe viewing screens
│   ├── widgets/                    # Reusable UI components
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   └── loading_overlay.dart
│   │   ├── audio/                  # Audio-specific widgets
│   │   └── recipe/                 # Recipe-specific widgets
│   └── utils/                      # Utility functions
├── assets/
│   ├── images/                     # Image assets
│   └── audio/                      # Audio assets
└── pubspec.yaml                    # Dependencies and configuration
```

## Key Flutter Features Implemented

- **Authentication Flow**: Login/Signup with JWT token management
- **State Management**: Provider pattern for reactive UI updates
- **Custom UI Components**: Korean-friendly design system with custom theme
- **HTTP Client**: Dio-based API service with error handling and interceptors
- **Local Storage**: SharedPreferences wrapper for token and user data persistence
- **Responsive Design**: Gradient backgrounds, custom buttons, and modern UI elements

## Security

- JWT-based authentication (HS256/RS256)
- Audio file access control by user ownership
- API endpoint protection with Bearer token validation
- Secure token storage in Flutter using SharedPreferences