from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api import router

app = FastAPI(title="Book Cover Speed Dating API")

# --- CORS MIDDLEWARE ---
# Required for the Flutter frontend to communicate with the backend.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Include the routes from api.py
# We add a prefix so all routes start with /api (e.g., /api/books/...)
app.include_router(router, prefix="/api")

@app.get("/")
async def root():
    return {"message": "Judge a Book API is running"}