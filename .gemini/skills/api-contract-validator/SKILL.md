---
name: api-contract-validator
description: Validates the API contract between Open Library, the FastAPI backend, and the Flutter frontend. Use this when changes are made to data models, DTOs, or when external API behavior is suspected to have changed.
---

# API Contract Validator

This skill ensures that data flows correctly from the Open Library API through the backend and into the Flutter frontend.

## Workflows

### 1. Validate Open Library Response
Use the provided script to verify that Open Library's response still matches our backend's expectations.

```bash
# From the project root
python .gemini/skills/api-contract-validator/scripts/check_open_library.py [subject]
```

### 2. Verify Internal Contract
When modifying `backend/app/api.py` or `frontend/lib/networking/dto/`, compare the changes against the [contract_spec.md](references/contract_spec.md).

- **Backend Changes**: Ensure `response_model` in FastAPI matches the spec.
- **Frontend Changes**: Ensure `fromJson` and `toJson` methods in Dart DTOs match the spec.

## Reference Materials
- [Open Library API Reference](references/open_library_api.md)
- [Internal Contract Specification](references/contract_spec.md)

## Troubleshooting
If validation fails, check if:
1. Open Library has changed their field names (e.g., `author_name` -> `authors`).
2. The backend is correctly filtering out books without `cover_i`.
3. The frontend DTO is expecting a non-nullable field that the backend might return as null.
