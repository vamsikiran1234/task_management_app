# Flodo AI Take-Home Assignment - Task Management App

This repository contains a full Track A submission for the Flodo AI take-home assignment.

## Track And Stretch Goal

- Selected Track: Track A (Flutter frontend + Django REST backend)
- Backend Framework: Django + Django REST Framework
- Database: SQLite
- Stretch Goal: Debounced autocomplete search (300 ms) + highlighted title matches

## Core Features Implemented

- Task model with required fields:
	- Title
	- Description
	- Due Date
	- Status (To-Do, In Progress, Done)
	- Blocked By (optional, one existing task)
- Main list screen with:
	- Search by title
	- Filter by status
	- Blocked task visual distinction until dependency is done
- Create, update, delete task workflows
- Draft persistence for create form when navigating back/minimizing
- Simulated 2-second delay on create and update operations
- Save button loading state and duplicate-submit prevention
- Debounced search and query match highlighting (stretch)

## UI/UX Notes

- Premium dark, futuristic visual direction with refined spacing and hierarchy
- Status chips, blocked-state cues, and polished card styling
- Improved form ergonomics and action affordances
- Smooth transitions and responsive interaction feedback

## Architecture Overview

### Frontend (Flutter)

- State management: Provider + ChangeNotifier
- Layering:
	- Domain: task entities and status enum
	- Data: API service and repository
	- Presentation: screens, providers, widgets
- Local persistence:
	- SharedPreferences for task draft persistence

### Backend (Django)

- REST API built with DRF viewsets and serializers
- SQLite for local persistence
- Validation rules include:
	- Required field checks
	- No self-blocking
	- No circular dependency
	- Protected delete when dependents exist

## API Summary

Base URL:

- Local desktop: http://127.0.0.1:8000/api

Main endpoints:

- GET /api/tasks/
- POST /api/tasks/
- PATCH /api/tasks/{id}/
- DELETE /api/tasks/{id}/
- GET /api/health/

Query params:

- q: title contains search
- status: TO_DO | IN_PROGRESS | DONE

## Setup Instructions

### Prerequisites

- Flutter SDK installed
- Python 3.12+
- Git

### 1. Clone And Open

1. Clone this repository.
2. Open the project root in VS Code.

### 2. Backend Setup (Django)

1. Create and activate virtual environment if needed.
2. Install dependencies:

```bash
cd backend
..\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

3. Apply migrations:

```bash
..\.venv\Scripts\python.exe manage.py migrate
```

4. Run backend server:

```bash
..\.venv\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

5. Verify backend health:

- http://127.0.0.1:8000/api/health/

### 3. Frontend Setup (Flutter)

1. Install Flutter dependencies:

```bash
flutter pub get
```

2. Run app for emulator (Android):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

3. Run app for physical device on same network:

```bash
flutter run --dart-define=API_BASE_URL=http://<YOUR_PC_LAN_IP>:8000/api
```

4. Run app with USB reverse tunneling (recommended when using USB debugging):

```bash
adb reverse tcp:8000 tcp:8000
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

### 4. Windows USB Debugging Setup (Exact Commands)

If `adb` is not available globally in PATH, run it with the full executable path.

1. Find the `adb.exe` location on your laptop.

How to find it in plain English:

- Open File Explorer.
- Go to your Android SDK folder.
- Open `platform-tools`.
- Confirm `adb.exe` exists there.

Common Windows location pattern:

- `C:\Users\<YourUserName>\AppData\Local\Android\Sdk\platform-tools\adb.exe`

2. Set that path in a PowerShell variable (replace with your own path):

```powershell
$adb = "C:\Users\<YourUserName>\AppData\Local\Android\Sdk\platform-tools\adb.exe"
```

3. Verify the connected device:

```powershell
& $adb devices
```

Expected output includes your device with `device` state.

4. Verify ADB installation details:

```powershell
& $adb version
```

5. Create reverse tunnel from phone port 8000 to laptop port 8000:

```powershell
& $adb reverse tcp:8000 tcp:8000
```

Expected output:

```text
8000
```

6. Start Django backend (from `backend` folder):

```powershell
& "..\.venv\Scripts\python.exe" manage.py runserver 127.0.0.1:8000
```

7. Run Flutter app from project root:

```powershell
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

8. If reverse mapping is already used and you want to reset it:

```powershell
& $adb reverse --remove tcp:8000
```

## Test And Quality Commands

Frontend:

```bash
flutter analyze
flutter test
```

Backend:

```bash
cd backend
..\.venv\Scripts\python.exe manage.py check
..\.venv\Scripts\python.exe manage.py test
```

## Assignment Artifacts

- Product planning and acceptance docs are in the docs folder:
	- docs/specification.md
	- docs/acceptance-criteria.md
	- docs/test-matrix.md
	- docs/api-contract.md
	- docs/definition-of-done.md
- Demo support files:
	- docs/demo-script.md
	- docs/submission-checklist.md

## AI Usage Report

AI tools were used to accelerate architecture planning, API scaffolding, UI iteration, and test hardening.

### Helpful Prompts Used

- Convert assignment requirements into user stories, acceptance criteria, and test matrix.
- Implement Track A backend with Django + DRF using strict task validation and blocked dependency rules.
- Build Flutter Provider architecture with CRUD, draft persistence, loading-state hardening, and blocked task visuals.
- Add debounced search and title match highlighting while preserving existing behavior.
- Improve UI to premium dark, futuristic style without breaking core flows.

### Example Of Bad AI Output And Fix

- Issue: During UI redesign, a malformed widget tree caused syntax errors in task card rendering.
- Fix: Manually corrected widget nesting and bracket structure, then verified with flutter analyze and flutter test.

## What I Am Proud Of

- One key decision I’m proud of is handling task dependencies consistently across the backend and UI, ensuring blocked tasks behave correctly and preventing invalid task relationships.
- Requirement fidelity: all must-have features implemented and validated.
- Strong dependency handling for blocked tasks across model, API, and UI layers.
- Practical reliability under real-device networking constraints with explicit connectivity guidance.
- Balanced delivery: polished UX plus testable architecture.
