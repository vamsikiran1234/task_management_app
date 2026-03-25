# API Contract v1 (Phase 0)

Base URL:
- Local: http://127.0.0.1:8000/api

Content Type:
- Request: application/json
- Response: application/json

## 1. Data Shape
Task object:
{
  "id": 1,
  "title": "Prepare sprint demo",
  "description": "Create slides and walkthrough",
  "due_date": "2026-03-30",
  "status": "TO_DO",
  "blocked_by": 3,
  "is_blocked": true,
  "created_at": "2026-03-25T09:30:00Z",
  "updated_at": "2026-03-25T09:30:00Z"
}

Field notes:
1. blocked_by is nullable.
2. is_blocked is computed by backend for easy frontend rendering.
3. status allowed values: TO_DO, IN_PROGRESS, DONE.

## 2. Endpoints
### 2.1 List Tasks
GET /tasks
Query params:
1. q: optional title search (contains, case-insensitive)
2. status: optional enum filter

Success 200:
{
  "count": 2,
  "results": [Task, Task]
}

### 2.2 Get Single Task
GET /tasks/{id}
Success 200: Task
Not found 404: error payload

### 2.3 Create Task
POST /tasks
Request body:
{
  "title": "Task",
  "description": "Details",
  "due_date": "2026-03-30",
  "status": "TO_DO",
  "blocked_by": null
}
Behavior:
- Simulated 2-second delay before response.
- Validation must reject self-blocking and cycles.

Success 201: Task
Validation 400: field errors

### 2.4 Update Task
PUT /tasks/{id}
PATCH /tasks/{id}
Behavior:
- Simulated 2-second delay before response.
- Same validation rules as create.

Success 200: Task
Validation 400: field errors
Not found 404

### 2.5 Delete Task
DELETE /tasks/{id}
Behavior:
- If task is blocker for other tasks, reject delete.

Success 204: no body
Failure 400 or 409:
{
  "detail": "Cannot delete task because other tasks depend on it."
}

## 3. Error Schema
Validation error example (400):
{
  "errors": {
    "title": ["This field is required."],
    "blocked_by": ["Task cannot block itself."]
  },
  "message": "Validation failed"
}

Generic error example (500/timeout mapping):
{
  "message": "Unexpected server error"
}

## 4. Frontend Integration Notes
1. Frontend should disable Save while create/update request is active.
2. Frontend should show loading indicator for about 2 seconds during create/update.
3. Frontend should consume is_blocked for card style decisions.
4. Search input should be debounced at 300 ms for stretch goal.

## 5. Versioning
Contract version: v1
Future changes should be backward-compatible or versioned under /api/v2.