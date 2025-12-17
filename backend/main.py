import random
import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI()

# --- 1. DATA MODELS (Pydantic) ---
# These define the structure of the data your Flutter app will receive.
# This ensures strict typing and automatic documentation.

class Book(BaseModel):
    title: str
    author: str
    cover_url: Optional[str] = None # We'll build the full URL here for easier Flutter usage
    open_library_key: str

class SubjectResponse(BaseModel):
    subject: str

class BookListResponse(BaseModel):
    subject: str
    books: List[Book]


# --- 2. HARDCODED DATA ---
# A curated list of interesting subjects to randomize the "Discovery" aspect.
SUBJECTS = [
    "science_fiction", "fantasy", "mystery", "romance", "horror",
    "historical_fiction", "robots", "pizza", "pirates", "time_travel",
    "vikings", "cyberpunk", "gardening", "minimalism", "basketball"
]


# --- 3. ENDPOINTS ---

@app.get("/")
async def root():
    return {"message": "Judge a Book API is running"}

@app.get("/api/subjects/random", response_model=SubjectResponse)
async def get_random_subject():
    """
    Returns a random subject to trigger the UI 'discovery' flow.
    """
    selected_subject = random.choice(SUBJECTS)
    return {"subject": selected_subject}


@app.get("/api/books/{subject}", response_model=BookListResponse)
async def get_books_by_subject(subject: str):
    """
    1. Calls Open Library Search API.
    2. Cleans the messy JSON.
    3. Returns a simple list of books.
    """
    # Open Library Search Endpoint
    url = "https://openlibrary.org/search.json"
    
    # We limit fields to keep the packet small and limit to 15 results
    params = {
        "q": subject,
        "limit": 15,
        "fields": "title,author_name,cover_i,key" 
    }

    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(url, params=params)
            response.raise_for_status()
            data = response.json()
        except httpx.HTTPError as e:
            raise HTTPException(status_code=502, detail="Failed to fetch data from Open Library")

    clean_books = []

    # --- DATA CLEANING LOGIC ---
    for doc in data.get("docs", []):
        # 1. Handle Missing Authors
        authors = doc.get("author_name", ["Unknown Author"])
        primary_author = authors[0] if authors else "Unknown Author"

        # 2. Handle Covers
        # Open Library returns a 'cover_i' integer. We need to build the URL.
        # If no cover_i exists, we can send None or a placeholder.
        cover_id = doc.get("cover_i")
        cover_url = f"https://covers.openlibrary.org/b/id/{cover_id}-L.jpg" if cover_id else None

        # 3. Create Clean Book Object
        # We filter out books without covers if you want the UI to be purely visual
        if cover_url: 
            book = Book(
                title=doc.get("title", "Untitled"),
                author=primary_author,
                cover_url=cover_url,
                open_library_key=doc.get("key", "")
            )
            clean_books.append(book)

    return {
        "subject": subject,
        "books": clean_books
    }

# --- 4. RUNNER ---
# To run: uvicorn main:app --reload