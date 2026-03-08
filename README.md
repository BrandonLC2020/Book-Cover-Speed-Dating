# Book Cover Speed Dating

Discover your next favorite book with a swipe! This project is a mobile application that uses a "Tinder-style" card-swiping interface to make book discovery fun and visual. Users are presented with book covers from a random subject and can swipe right to save a book or left to pass.

*(A GIF demonstrating the app's swiping interface would go here)*

## 🏛️ Tech Stack & Architecture

This project is a full-stack application composed of a Flutter frontend and a Python (FastAPI) backend. The backend acts as a proxy and data cleaner for the public Open Library API.

```mermaid
graph TD
    subgraph "Frontend (Flutter)"
        A["User Interface <br/>(Material 3, card_swiper)"]
        B["State Management <br/>(flutter_bloc)"]
        C["HTTP Client <br/>(dio)"]
    end

    subgraph "Backend (FastAPI)"
        D["API Endpoints <br/>(/subjects, /books)"]
        E["Data Cleaning & Formatting"]
        F["Pydantic Models"]
    end

    subgraph External Service
        G["Open Library API"]
    end

    A --> B
    B --> C
    C -- HTTP Request --> D
    D --> E
    E -- Fetches & Processes Data --> G
    G -- Raw JSON --> E
    E -- Cleaned Book List --> D
    F -- Validates Data --> D

    D -- JSON Response --> C
```

```mermaid
graph TD
    subgraph Frontend Technologies
        F["Flutter Framework"]
        SM("State Management:<br/>flutter_bloc")
        UI("UI Components:<br/>card_swiper,<br/>Material 3")
        HTTP("HTTP Client:<br/>dio")
        IL("Image Loading:<br/>cached_network_image")
    end

    subgraph Backend Technologies
        B["FastAPI Framework"]
        B_HTTP("HTTP Client:<br/>httpx")
        B_Server("Server:<br/>Uvicorn")
    end

    F --- SM
    F --- UI
    F --- HTTP
    F --- IL

    B --- B_HTTP
    B --- B_Server
```

- **Frontend**:
    - **Framework**: Flutter
    - **State Management**: `flutter_bloc`
    - **UI**: `card_swiper` for the core swipe mechanic
    - **HTTP Client**: `dio` for network requests
    - **Image Loading**: `cached_network_image` for performance

- **Backend**:
    - **Framework**: FastAPI
    - **HTTP Client**: `httpx` for making asynchronous API calls to Open Library
    - **Server**: Uvicorn

## ✨ Features

- **Random Discovery**: Starts the user journey with a randomly selected book subject.
- **Swipe Interface**: An intuitive, visual-first way to browse books.
- **Dynamic Data**: Fetches and processes data in real-time from the Open Library API.
- **Error Handling**: Gracefully handles potential failures from the external API.
- **Clean Architecture**: Separates concerns between the UI, state management, and backend services.
- **Visual Focus**: Filters out books that do not have a cover image to ensure a consistent user experience.

## ⚙️ How It Works

The application flow is designed to be simple and engaging.

```mermaid
sequenceDiagram
    participant User
    participant Flutter App
    participant FastAPI Backend
    participant Open Library API

    User->>Flutter App: Opens App
    Flutter App->>FastAPI Backend: GET /api/subjects/random
    FastAPI Backend-->>Flutter App: {"subject": "science_fiction"}
    Flutter App->>FastAPI Backend: GET /api/books/science_fiction
    Note right of Flutter App: Displays loading indicator
    FastAPI Backend->>Open Library API: GET /search.json?q=science_fiction
    Open Library API-->>FastAPI Backend: Raw Book Data (JSON)
    Note left of FastAPI Backend: Filters out books without covers, <br/>cleans author names, <br/>constructs image URLs.
    FastAPI Backend-->>Flutter App: Cleaned Book List (JSON)
    Flutter App->>User: Displays Book Covers for Swiping
    User->>Flutter App: Swipes Left/Right
```

## 🚀 Getting Started

### Prerequisites

- **Flutter**: Version 3.9.2 or higher.
- **Python**: Version 3.14 or higher.
- **Poetry**: For backend dependency management.

### 1. Backend Setup

The backend server fetches and prepares the data for the frontend.

```bash
# 1. Navigate to the backend directory
cd backend

# 2. Install dependencies using Poetry
poetry install

# 3. Run the development server
poetry run uvicorn app.main:app --reload
```
The API will now be running at `http://127.0.0.1:8000`.

### 2. AWS Lambda Deployment (Optional)

The backend is also ready for deployment to AWS Lambda.

```bash
# 1. Navigate to the backend directory
cd backend

# 2. Build with SAM
sam build

# 3. Deploy to AWS
sam deploy --guided
```
See [README_LAMBDA.md](backend/README_LAMBDA.md) for more details.

### 3. Frontend Setup

The Flutter app consumes the backend API to display the books.

```bash
# 1. Navigate to the frontend directory
cd frontend

# 2. Install dependencies
flutter pub get

# 3. Run the application
# (Ensure an emulator is running or a device is connected)
flutter run
```

*Note: The backend is configured with CORS to allow requests from any origin, which simplifies development.*

## 📡 API Endpoints

The backend exposes a few simple endpoints to drive the app.

| Method | Endpoint                 | Description                                                                                                   |
|--------|--------------------------|---------------------------------------------------------------------------------------------------------------|
| `GET`  | `/api/subjects/random`   | Returns a single random subject (e.g., `{"subject": "cyberpunk"}`) to kick off the discovery process.         |
| `GET`  | `/api/books/{subject}`   | Fetches a list of books for the given subject from Open Library. It cleans the data and filters out entries without cover images. |

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---
*Copyright (c) 2025 Brandon Lamer-Connolly*