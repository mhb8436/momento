# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MOMENTO is an emotional cooking archiving app that records family cooking recipes through voice and stories, allowing warm sharing among family members. The app focuses on capturing mom's cooking methods through voice recordings and converting them into organized recipes using AI.

**Key Features:**
- Voice recording of cooking instructions
- STT (Speech-to-Text) conversion using OpenAI Whisper
- OCR (Optical Character Recognition) for image text extraction
- URL extraction from YouTube videos and blog posts (server-side security)
- Text input for manual recipe entry
- Recipe organization and summarization using GPT
- Family sharing with personalized recommendations
- Senior-friendly interface with automatic suggestions
- **Credit-based monetization system** with daily free credits and auto-recharge options

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
- YouTube Data API v3 integration (server-side security)
- Web scraping with BeautifulSoup for blog content
- Audio file storage and processing
- SQLAlchemy 2.0 with async support
- **Credit management system** with daily limits and auto-recharge

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
POST /recipes        # Save processed recipe (requires 1 credit)
GET  /recipes        # List user recipes
GET  /recipes/:id    # Recipe details
DELETE /recipes/:id  # Delete recipe
PUT  /recipes/:id    # Update recipe
```

### Credit Management Endpoints
```
GET  /credits/balance           # Get current credit balance and settings
POST /credits/purchase          # Purchase credit package
POST /credits/verify-purchase   # Verify in-app purchase
GET  /credits/packages          # List available credit packages
GET  /credits/payment-history   # User's payment history
GET  /credits/usage-stats       # Credit usage statistics
POST /credits/test-deduct       # Test credit deduction (dev only)
```

## Database Schema

### Core Tables
- `users`: User authentication and profile data
- `user_credits`: Credit balance and usage tracking
- `credit_packages`: Available credit packages catalog
- `payment_history`: Purchase transactions and verifications
- `api_usage_logs`: API usage tracking for analytics
- `audio_files`: Uploaded audio recordings and transcripts
- `recipes`: Organized recipe data with ingredients, steps, and tips
- Relations: User → Credits → API Usage → Recipes

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
│   │   ├── credit.dart             # Credit balance and package models
│   │   ├── audio_file.dart
│   │   └── recipe.dart
│   ├── providers/                  # State management (Provider pattern)
│   │   ├── auth_provider.dart
│   │   ├── credit_provider.dart    # Credit balance and purchase management
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
│   │   ├── credit/                 # Credit store and usage screens
│   │   ├── audio/                  # Audio recording screens
│   │   └── recipe/                 # Recipe viewing screens
│   ├── widgets/                    # Reusable UI components
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   └── loading_overlay.dart
│   │   ├── credit/                 # Credit dialogs and status widgets
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
- **Credit Management**: Dynamic credit balance display, purchase flows, and usage tracking
- **State Management**: Provider pattern for reactive UI updates
- **Custom UI Components**: Korean-friendly design system with custom theme
- **HTTP Client**: Dio-based API service with error handling and interceptors
- **Local Storage**: SharedPreferences wrapper for token and user data persistence
- **In-App Purchases**: Integration with iOS App Store and Google Play billing
- **Responsive Design**: Gradient backgrounds, custom buttons, and modern UI elements

## Credit System

**MOMENTO uses a credit-based monetization model to ensure sustainable AI service costs while providing fair usage to users.**

### Credit Policy
- **Daily Free Credits**: 2 free credits per day (configurable from backend)
- **Initial Signup Bonus**: 5 credits for new users
- **Recipe Generation Cost**: 1 credit per recipe (voice, text, OCR, URL)
- **Recipe Improvement Cost**: 1 credit per improvement

### Credit Packages
1. **One-time Purchases**:
   - Starter Package: 10 credits - ₩2,900 (₩290/credit)
   - Family Package: 30 credits - ₩7,900 (₩263/credit)
   - Premium Package: 100 credits - ₩19,900 (₩199/credit)

2. **Auto-recharge Subscriptions**:
   - Monthly Auto-recharge: 50 credits - ₩9,900/month (₩198/credit)
   - Yearly Auto-recharge: 100 credits - ₩99,900/year (₩83/credit)

### Technical Implementation
- **Dynamic Configuration**: All credit values are fetched from backend API
- **Daily Reset Logic**: Free credits reset automatically at midnight
- **Frontend Flexibility**: No hardcoded credit values in Flutter app
- **Cost Safety**: Credit-only model prevents unlimited API usage

### Database Schema
```sql
-- Core credit tracking table
user_credits:
  - balance: Current purchased credit balance
  - free_daily_used: Today's free credit usage (0-2)
  - last_daily_reset: Last daily reset timestamp
  - has_auto_recharge: Auto-recharge subscription status
  - auto_recharge_expires_at: Auto-recharge expiration date
  - total_purchased: Lifetime purchased credits
  - total_used: Lifetime used credits
```

### API Cost Management
- **OpenAI Whisper**: ~₩100 per audio transcription
- **OpenAI GPT-3.5**: ~₩300-500 per recipe generation
- **Total API Cost**: ~₩500 per recipe
- **Minimum Credit Price**: ₩83 (yearly auto-recharge)
- **Safety Margin**: Very high profitability with cost control

## Security

- JWT-based authentication (HS256/RS256)
- Audio file access control by user ownership
- API endpoint protection with Bearer token validation
- Secure token storage in Flutter using SharedPreferences
- **Credit validation** before all AI API calls to prevent cost overruns

---

## 🔥 CRITICAL SYSTEM NOTES

### Credit System Implementation (2025-09-12)

**⚠️ IMPORTANT**: MOMENTO now uses a **credit-only monetization model** (NO unlimited subscriptions).

**Key Changes Made**:
1. **Removed unlimited subscription model** to prevent OpenAI API cost explosion
2. **Implemented daily free credits** (2 per day) with automatic reset
3. **Added auto-recharge subscriptions** that provide bulk credits, not unlimited usage
4. **Dynamic configuration** - all credit values fetched from backend API (no hardcoding)
5. **Credit validation** on every AI operation to ensure cost control

**Business Model**:
- **API Cost**: ~₩500 per recipe generation
- **Credit Pricing**: ₩83-290 per credit depending on package
- **Safety Margin**: High profitability with predictable costs

**Technical Implementation**:
- Backend: `DAILY_FREE_CREDITS`, `has_auto_recharge` model
- Frontend: Dynamic credit display, purchase flows, validation dialogs
- Database: `user_credits` table with daily reset logic

**Why This Matters**:
Previous unlimited subscription model could have caused catastrophic API costs if users generated many recipes. The new credit model ensures sustainable business operations while maintaining user value.