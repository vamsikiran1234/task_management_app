# Acceptance Criteria (Phase 0)

## 1. Task Model
### AC-1 Required Fields
Given the user is creating or updating a task
When title, description, due_date, and status are all valid
Then the task is accepted and persisted.

### AC-2 Missing Required Fields
Given the user submits a task with any required field missing
When validation runs
Then API returns 400 with field-level validation errors.

### AC-3 Blocked By Optional
Given blocked_by is omitted
When the task is submitted
Then task is created without dependency.

### AC-4 Self Blocking Forbidden
Given blocked_by equals current task id
When validation runs
Then API rejects the request with clear error message.

### AC-5 Circular Blocking Forbidden
Given task dependency would create a cycle
When validation runs
Then API rejects the request with clear error message.

## 2. Main List View
### AC-6 List Visibility
Given tasks exist
When main view opens
Then all tasks are listed according to current query/filter.

### AC-7 Blocked Visual Distinction
Given task B depends on task A and task A status is not DONE
When task list is rendered
Then task B appears visually distinct as blocked.

### AC-8 Unblock Transition
Given task B depends on task A
When task A becomes DONE
Then task B no longer appears blocked after refresh/state update.

## 3. CRUD Operations
### AC-9 Create
Given valid input
When user taps Save
Then one create request is sent, loading state is shown, and new task appears after success.

### AC-10 Update
Given an existing task and valid changes
When user taps Save
Then one update request is sent, loading state is shown, and task reflects updates after success.

### AC-11 Delete
Given a task with no dependents
When user confirms delete
Then task is deleted and removed from list.

### AC-12 Delete with Dependents
Given a task is referenced by blocked_by in other tasks
When user attempts delete
Then API rejects delete with conflict-style validation message.

## 4. Draft Persistence
### AC-13 Preserve Draft on Back
Given user has typed task fields in create view
When user navigates back without saving
Then reopening create view restores typed values.

### AC-14 Preserve Draft on Minimize
Given user has typed task fields in create view
When app is minimized and resumed
Then typed values remain present.

### AC-15 Clear Draft on Success
Given create succeeds
When user reopens create view
Then prior draft is cleared.

## 5. Search and Filter
### AC-16 Search by Title
Given tasks with different titles
When user enters search text
Then list shows title matches only.

### AC-17 Status Filter
Given tasks in multiple statuses
When user selects a status filter
Then list shows tasks for selected status only.

### AC-18 Combined Query and Filter
Given query and status are both set
When list refreshes
Then results satisfy both query and status conditions.

## 6. Async Delay and Submit Guard
### AC-19 Simulated Delay
Given create or update is requested
When backend processes request
Then operation takes approximately 2 seconds before response.

### AC-20 UI Responsiveness
Given save request is in-flight
When user interacts with screen
Then UI remains responsive except Save action is disabled.

### AC-21 No Double Submit
Given save request is in-flight
When user taps Save multiple times
Then only one API request is executed.

## 7. Stretch Goal
### AC-22 Debounced Search
Given user types rapidly
When input changes continuously
Then search execution is delayed by 300 ms after typing stops.

### AC-23 Highlight Matching Text
Given search query matches part of task title
When list is shown
Then matching substring in title is highlighted.

## 8. Error Handling
### AC-24 Backend Validation Errors
Given backend returns 400
When frontend receives response
Then field-level or form-level errors are clearly shown.

### AC-25 Server Failure
Given backend returns 500 or network timeout
When frontend receives failure
Then user sees retry-capable error state and no data corruption occurs.