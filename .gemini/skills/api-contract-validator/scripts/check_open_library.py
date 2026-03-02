import httpx
import sys
import json
from pydantic import BaseModel, Field
from typing import List, Optional

class OpenLibraryDoc(BaseModel):
    title: str = "Untitled"
    author_name: Optional[List[str]] = Field(default_factory=lambda: ["Unknown Author"])
    cover_i: Optional[int] = None
    key: str = ""

class OpenLibraryResponse(BaseModel):
    docs: List[OpenLibraryDoc]

async def check_contract(subject: str = "science_fiction"):
    url = "https://openlibrary.org/search.json"
    params = {
        "q": subject,
        "limit": 5,
        "fields": "title,author_name,cover_i,key"
    }
    
    print(f"Checking Open Library contract for subject: {subject}...")
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(url, params=params)
            response.raise_for_status()
            data = response.json()
            
            # Validate against schema
            ol_response = OpenLibraryResponse(**data)
            
            print("✅ Success: Open Library response matches the expected contract.")
            print(f"Found {len(ol_response.docs)} books.")
            
            # Check for at least one book with a cover (critical for our app)
            has_cover = any(doc.cover_i for doc in ol_response.docs)
            if has_cover:
                print("✅ Success: At least one book has a cover ID.")
            else:
                print("⚠️ Warning: No books in the sample had cover IDs. This might impact the UI.")
                
        except Exception as e:
            print(f"❌ Error: Contract validation failed: {str(e)}")
            sys.exit(1)

if __name__ == "__main__":
    import asyncio
    subject = sys.argv[1] if len(sys.argv) > 1 else "science_fiction"
    asyncio.run(check_contract(subject))
