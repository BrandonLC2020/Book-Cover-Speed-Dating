# Internal API Contract

## Overview
This contract defines the structure of the data exchanged between the FastAPI backend and the Flutter frontend.

## 1. Random Subject Endpoint
**Endpoint:** `GET /api/subjects/random`
**Response:**
```json
{
  "subject": "String"
}
```

## 2. Books by Subject Endpoint
**Endpoint:** `GET /api/books/{subject}`
**Parameters:**
- `subject` (path): The subject name.
- `page` (query, optional): The page number.
**Response:**
```json
{
  "subject": "String",
  "books": [
    {
      "title": "String",
      "author": "String",
      "cover_url": "String",
      "open_library_key": "String"
    }
  ]
}
```

## Mapping: Open Library to Backend
| Open Library Field | Backend Field | Transformation |
|--------------------|---------------|----------------|
| `title`            | `title`       | Default: "Untitled" |
| `author_name`      | `author`      | First author in list or "Unknown Author" |
| `cover_i`          | `cover_url`   | Built as URL or filtered out if missing |
| `key`              | `open_library_key` | Direct mapping |
