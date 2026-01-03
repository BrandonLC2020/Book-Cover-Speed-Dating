# Book Cover Speed Dating

**Book Cover Speed Dating** is a full-stack application that puts a fun twist on book discovery. Adopting the "speed dating" (or swiping) interface popular in dating apps, it allows users to judge books based on their covers before diving into the details.

## 🚀 Features

* **Discovery Flow**: The app randomly selects a subject (genre) to start the discovery process.
* **Visual-First Interface**: Filters books specifically for those with cover images available.
* **Swipe Mechanics**: Built using Flutter and `card_swiper` for intuitive navigation.
* **Real-time Data**: Fetches book data dynamically from the **Open Library Search API**.
* **State Management**: Robust state handling using the **BLoC** (Business Logic Component) pattern.

## 🛠 Tech Stack

### Backend

* **Language**: Python (requires v3.14+)
* **Framework**: FastAPI
* **Dependency Management**: Poetry
* **HTTP Client**: HTTPX (Async)

### Frontend

* **Framework**: Flutter (Dart)
* **Design**: Material 3 (Deep Purple Theme)
* **Key Packages**:
* `flutter_bloc`: State management.
* `card_swiper`: Swiping UI.
* `cached_network_image`: Efficient image loading.



---

## ⚙️ Installation & Running

### 1. Backend Setup (FastAPI)

The backend handles the connection to Open Library and cleans the data for the UI.

**Prerequisites:**

* Python
* Poetry

```bash
# Navigate to the backend directory
cd backend

# Install dependencies
poetry install

# Run the server
# The API will be available at http://127.0.0.1:8000
poetry run uvicorn app.main:app --reload

```

### 2. Frontend Setup (Flutter)

The frontend visualizes the books and handles user interaction.

**Prerequisites:**

* Flutter SDK (Environment SDK: ^3.9.2)

```bash
# Navigate to the frontend directory
cd frontend

# Install dependencies
flutter pub get

# Run the application (Ensure an emulator is running or device is connected)
flutter run

```

*Note: The backend has CORS enabled for all origins, so the frontend should connect easily during development.*

---

## 📡 API Endpoints

The backend exposes the following endpoints (prefixed with `/api`):

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/` | Health check to confirm the API is running. |
| `GET` | `/api/subjects/random` | Returns a random subject (e.g., "sci-fi", "robots", "pizza") to trigger the discovery flow. |
| `GET` | `/api/books/{subject}` | Fetches a list of books for the given subject from Open Library, filtering out entries without covers. |

## 📂 Project Structure

```text
.
├── backend/
│   ├── app/
│   │   ├── api.py          # API Endpoints & Logic
│   │   ├── main.py         # FastAPI App & CORS setup
│   │   └── models.py       # Pydantic Data Models
│   └── pyproject.toml      # Backend dependencies
└── frontend/
    ├── lib/
    │   ├── bloc/           # State Management (BookSwipeBloc)
    │   ├── components/     # UI Components (Cards, Overlays)
    │   ├── screens/        # App Screens
    │   └── main.dart       # Entry point
    └── pubspec.yaml        # Frontend dependencies

```

## 📝 License

This project is licensed under the **MIT License**.

Copyright (c) 2025 Brandon Lamer-Connolly.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files, to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software.