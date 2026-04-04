# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Book Cover Speed Dating** is a Tinder-style book discovery app. Users swipe through book covers fetched from the Open Library API. The backend acts as a data-cleaning proxy — it filters out books without cover images and normalizes the Open Library response before sending it to the Flutter frontend.

## Commands

### Backend (run from `backend/`)

```bash
poetry install                            # Install dependencies
poetry run uvicorn app.main:app --reload  # Dev server at http://127.0.0.1:8000
poetry run pytest                         # Run all tests
poetry run pytest tests/test_api.py::test_name  # Run a single test
```

### Frontend (run from `frontend/`)

```bash
flutter pub get    # Install dependencies
flutter run        # Run on connected device/emulator
flutter analyze    # Lint
flutter test       # Run widget tests
```

### Infrastructure (run from `infra/`)

```bash
terraform init     # Initialize
terraform plan     # Preview changes
terraform apply    # Apply changes
```

### AWS Lambda (run from `backend/`)

```bash
sam build                  # Build Lambda package
sam local start-api        # Local Lambda testing at port 3000
sam deploy --guided        # First-time deploy
```

## Architecture

### Request Flow

```
Flutter App → Backend (FastAPI) → Open Library API
                ↓
          Filters books without covers
          Normalizes fields (title, author, cover_url, key)
                ↓
          Returns cleaned JSON to app
```

### Backend (`backend/app/`)

- **`api.py`**: All routes, included in `main.py` under the `/api` prefix.
  - `GET /api/subjects/random` — returns one of 15 hardcoded subjects (e.g. `cyberpunk`, `pirates`, `robots`).
  - `GET /api/books/{subject}?page=1` — proxies Open Library search, filters books lacking a `cover_i`, constructs cover URLs, and returns `Book` objects.
- **`models.py`**: Pydantic models (`Book`, `SubjectResponse`, `BookListResponse`).
- **`main.py`**: FastAPI app setup, CORS (open `*`), and `handler` (Mangum wrapper for Lambda).

### Frontend (`frontend/lib/`)

- **State management**: BLoC pattern. Events/states are in `bloc/`. The main bloc is `BookSwipeBloc`.
- **Networking**: Dio client in `networking/`. Base URL is `http://localhost:8000`; for Android emulator use `http://10.0.2.2:8000` in `networking/dio_client.dart`.
- **Key screens**: `screens/` contains the swipe screen. `components/` has reusable widgets.
- **Models/DTOs**: `models/` for domain models, `networking/dto/` for API response mapping.

### Infrastructure (`infra/`)

Terraform scaffolding targeting AWS (us-east-1). The SAM template (`backend/template.yaml`) defines the Lambda function (Python 3.12, 512 MB, 30s timeout) with HTTP API Gateway.

## Key Conventions

- Backend routes always live in `api.py`; `main.py` only mounts the router.
- The Open Library query is capped at 15 results per page.
- CORS is intentionally open (`*`) for local development.
- AWS Lambda entrypoint is `app.main.handler` (the Mangum-wrapped FastAPI app).
