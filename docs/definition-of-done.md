# Definition of Done (Phase 0)

## 1. Functional Completion
1. All core assignment requirements are implemented and demonstrable.
2. Exactly one stretch goal is implemented: debounced autocomplete search with title match highlighting.
3. Simulated 2-second delay exists on create and update only.

## 2. Quality and Testing
1. Backend automated tests pass for model, serializer, and API endpoints.
2. Flutter unit/widget tests pass for key behaviors:
   - list loading
   - create/edit validation
   - draft persistence behavior
   - blocked card visual state logic
   - save loading and submit lock
   - debounce behavior
3. Manual test matrix execution completed with pass evidence.
4. No open P0/P1 issues.

## 3. Architecture and Maintainability
1. Backend code follows modular Django app structure and DRF best practices.
2. Flutter code follows layered structure with Provider-based state management.
3. No dead code or temporary hacks.
4. Linting and static analysis are clean or have documented acceptable exceptions.

## 4. UX Requirements
1. UI remains responsive during delayed save operations.
2. Save action is clearly disabled during in-flight create/update.
3. Blocked tasks are visually distinct until dependency is DONE.
4. Error states are actionable and understandable.

## 5. Documentation and Delivery
1. README includes:
   - setup steps for backend and frontend
   - selected track and stretch goal
   - architecture overview
   - AI usage report
2. Demo video checklist prepared and validated.
3. Commit history is atomic and meaningful.

## 6. Release Readiness Checklist
1. Clean clone setup verified.
2. Database migrations apply successfully.
3. App runs end-to-end with backend connected.
4. Core flows verified in demo order:
   - create
   - read/list
   - update
   - delete
   - draft restore
   - search/filter
   - blocked dependency behavior
   - stretch behavior

Completion is reached only when all checklist items are satisfied.