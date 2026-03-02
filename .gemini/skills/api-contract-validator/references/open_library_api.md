# Open Library Search API Reference

## Endpoint
`https://openlibrary.org/search.json`

## Query Parameters Used
- `q`: Search query (subject or title).
- `limit`: Number of results.
- `page`: Page number.
- `fields`: Specific fields to return.

## Expected Response Schema (subset used)
```json
{
  "docs": [
    {
      "title": "String",
      "author_name": ["String"],
      "cover_i": 12345,
      "key": "/works/OL12345W"
    }
  ]
}
```

## Cover URL Construction
Covers are constructed using the `cover_i` field:
`https://covers.openlibrary.org/b/id/{cover_i}-L.jpg`
