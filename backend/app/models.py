from pydantic import BaseModel
from typing import List, Optional

# --- DATA MODELS ---
# These define the structure of the data your Flutter app will receive.

class Book(BaseModel):
    title: str
    author: str
    cover_url: Optional[str] = None
    open_library_key: str

class SubjectResponse(BaseModel):
    subject: str

class BookListResponse(BaseModel):
    subject: str
    books: List[Book]