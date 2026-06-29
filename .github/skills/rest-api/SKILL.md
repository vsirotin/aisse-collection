---
name: rest-api
description: REST API skill that provides naming conventions and best practices for REST API development. 
metadata:
  author: vsirotin
  version: "1.1"
---

## REST Endpoint Naming Summary

- Use nouns, not verbs — HTTP methods express actions.
- Use plural nouns for collections and singular for items.
- Use lowercase with hyphens for readability.
- Keep nesting shallow — ideally one or two levels.
- Model actions as state changes or sub‑resources, not verbs.
- Use /api/... only when separating API routes from UI/static content.
CRUD uses HTTP methods, not endpoint names:
- POST /resources
- GET /resources / GET /resources/{id}
- PATCH /resources/{id}
- DELETE /resources/{id}
Use dedicated nouns for metadata like version:  /version  or /version/server