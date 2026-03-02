# GEMINI.md

## Project Overview
**Book Cover Speed Dating** is a full-stack application that provides a "Tinder-style" card-swiping interface for discovering books. Users swipe through book covers fetched from the Open Library API via a custom backend proxy.

- **Frontend**: Flutter application using Material 3, BLoC for state management, and Dio for networking.
- **Backend**: FastAPI (Python) service that acts as a data cleaner and proxy for the Open Library API, ensuring only books with valid covers are presented.

## Architecture
The project is divided into two main components:
- `backend/`: Python FastAPI application.
- `frontend/`: Flutter mobile/web application.

### Tech Stack
- **Frontend**: Flutter, `flutter_bloc`, `dio`, `card_swiper`, `cached_network_image`.
- **Backend**: FastAPI, `httpx`, `pydantic`.
- **External API**: Open Library API.

## Building and Running

### Prerequisites
- Flutter SDK (>= 3.9.2)
- Python (>= 3.14)
- Poetry (for backend dependency management)

### Backend Setup
```bash
cd backend
poetry install
poetry run uvicorn app.main:app --reload
```
The backend runs by default at `http://127.0.0.1:8000`.

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
```

## Development Conventions

### Backend (Python/FastAPI)
- Routes are defined in `backend/app/api.py` and included in `main.py` with the `/api` prefix.
- Uses `httpx` for asynchronous external API calls.
- CORS is enabled for all origins (`*`) to facilitate local development.

### Frontend (Flutter/Dart)
- **State Management**: Uses the BLoC (Business Logic Component) pattern. Look in `frontend/lib/bloc/` for event/state definitions.
- **Networking**: Uses `dio` for HTTP requests. API definitions are in `frontend/lib/networking/api/`.
    - **Base URL**: The default base URL is `http://localhost:8000`. For Android emulator development, this may need to be updated to `http://10.0.2.2:8000` in `frontend/lib/networking/dio_client.dart`.
- **UI**: Uses `card_swiper` for the main swiping mechanic.
- **Models**: Data Transfer Objects (DTOs) and models are located in `frontend/lib/networking/dto/` and `frontend/lib/models/`.

## Key Files
- `backend/app/main.py`: Entry point for the FastAPI server.
- `backend/app/api.py`: Backend route definitions.
- `frontend/lib/main.dart`: Entry point for the Flutter application.
- `frontend/pubspec.yaml`: Frontend dependencies and configuration.
- `backend/pyproject.toml`: Backend dependencies and configuration.
