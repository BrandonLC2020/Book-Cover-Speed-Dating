import random
import httpx
from fastapi import APIRouter, HTTPException
from .models import Book, SubjectResponse, BookListResponse

router = APIRouter()

# --- HARDCODED DATA ---
SUBJECTS = [
    "science_fiction", "fantasy", "mystery", "romance", "horror",
    "historical_fiction", "robots", "pizza", "pirates", "time_travel",
    "vikings", "cyberpunk", "gardening", "minimalism", "basketball"
]

# --- ENDPOINTS ---

@router.get("/subjects/random", response_model=SubjectResponse)
async def get_random_subject():
    """
    Returns a random subject to trigger the UI 'discovery' flow.
    """
    selected_subject = random.choice(SUBJECTS)
    return {"subject": selected_subject}


@router.get("/books/{subject}", response_model=BookListResponse)
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
            # We log the error internally here in a real app
            raise HTTPException(status_code=502, detail="Failed to fetch data from Open Library")

    clean_books = []

    # --- DATA CLEANING LOGIC ---
    for doc in data.get("docs", []):
        # 1. Handle Missing Authors
        authors = doc.get("author_name", ["Unknown Author"])
        primary_author = authors[0] if authors else "Unknown Author"

        # 2. Handle Covers
        # Open Library returns a 'cover_i' integer. We need to build the URL.
        cover_id = doc.get("cover_i")
        cover_url = f"https://covers.openlibrary.org/b/id/{cover_id}-L.jpg" if cover_id else None

        # 3. Create Clean Book Object
        # We filter out books without covers because this is a visual "Speed Dating" app
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