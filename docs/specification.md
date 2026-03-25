# Flodo AI Assignment - Product Specification (Phase 0)

## 1. Project Context
Build a Task Management application using Track A:
- Frontend: Flutter (Dart)
- Backend: Django + Django REST Framework
- Database: SQLite

The goal is strict requirement compliance with strong UX and testability.

## 2. In-Scope Features
### 2.1 Task Data Model
Each task has exactly these business fields:
1. title: text, required
2. description: text, required
3. due_date: date, required
4. status: enum, required
   - TO_DO
   - IN_PROGRESS
   - DONE
5. blocked_by: optional reference to one other existing task

Notes:
- blocked_by is nullable.
- A task cannot block itself.
- Circular dependency is rejected to avoid ambiguous behavior.

### 2.2 Screens
1. Main List View
   - Show all tasks
   - Search input by title
   - Status filter dropdown
   - Visual distinction for blocked tasks while prerequisite is not DONE
2. Task Create/Edit View
   - Inputs for all required fields
   - blocked_by dropdown from existing tasks
   - Save and cancel actions

### 2.3 Required Behavior
1. CRUD for tasks
2. Draft persistence for create flow
   - If user minimizes app or navigates back while typing, typed values must reappear when create view is reopened
3. Search by title
4. Filter by status
5. Simulated 2-second delay on create and update operations
   - UI remains responsive
   - Clear loading state
   - Save action cannot be triggered twice while request is active

### 2.4 Stretch Goal Selected
Debounced autocomplete search with highlighted match in task title.
- Debounce delay: 300 ms
- Matching part of title is visually highlighted in list card

## 3. UX and Interaction Rules
1. Blocked visual state
   - If task B.blocked_by = task A.id and task A.status != DONE, then task B card uses muted style and lock icon/tag.
2. Dependency resolution
   - If task A changes to DONE, all dependent tasks become unblocked in UI refresh.
3. Save behavior
   - Save button disabled while create/update is in-flight.
   - Spinner and action text indicate progress.
4. Draft lifecycle
   - Draft is cleared after successful create or explicit user clear action.

## 4. Non-Functional Requirements
1. Clean architecture and maintainable separation of concerns.
2. Deterministic API contract between backend and frontend.
3. Test coverage on critical behavior and edge cases.
4. Predictable error handling with user-friendly messages.

## 5. Constraints and Policies
1. Authentication and multi-user roles are out of scope.
2. Deleting a task that blocks other tasks is prevented by backend validation (safe default for assignment reliability).
3. Timezone handling for due_date uses local date semantics (date-only, no time component).

## 6. Release Criteria Linkage
Feature completion is considered valid only if acceptance criteria and test matrix scenarios are fully passing.