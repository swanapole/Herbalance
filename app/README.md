# Herbalance (Flutter)

MVP mobile app combining preventive health and mental wellness for Kenya.

## Features
- Onboarding with profile (region=KE, language=en) and explicit sensitive-data consent
- Assessments: breast/cervical/osteoporosis (heuristics) + stress check-in
- Alerts & reminders (in-app, persisted on backend)
- Privacy Center: export data (JSON), delete account
- Resources (Kenya): curated MOH/NHIF/mental health links
- On-device classifier stub; risk scores sent to backend

## Prereqs
- Flutter installed and on PATH. See https://docs.flutter.dev/get-started/install/windows
- Backend running at http://localhost:4000 or set your own URL via `--dart-define`.

## Run the App

1) Fetch packages
```bash
flutter pub get
```

2) Run (point to backend)
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:4000
```

Notes:
- From Android emulator, use `http://10.0.2.2:4000` instead of `localhost`.
- From iOS simulator, `http://localhost:4000` works by default.

## Project Structure
- `lib/main.dart` – entry point
- `lib/router.dart` – `go_router` routes
- `lib/theme.dart` – Material 3 theme
- `lib/constants.dart` – API base URL
- `lib/models/` – simple models
- `lib/services/` – `api_client.dart`, `storage.dart`, `classifier.dart`
- `lib/features/` – UI screens by feature

## Privacy-by-Design
- Minimal PII (email only by default). Explicit consent for sensitive data.
- Local scoring on-device. Only scores/answers sent to backend.
- Data export and account deletion available in Privacy Center.

## Backend Endpoints Used
- `POST /api/users` – create/update user
- `GET /api/users/{id}` – fetch user
- `DELETE /api/users/{id}` – delete user
- `GET /api/users/{id}/export` – export data
- `POST /api/assessments` – create assessment
- `GET /api/assessments/user/{userId}` – list assessments
- `POST /api/alerts` – create alert
- `GET /api/alerts/user/{userId}` – list alerts
- `GET /api/resources` – Kenya resources

## Next
- Push notifications (FCM) for reminders
- Real on-device ML models (TensorFlow Lite / Core ML)
- Multi-language support beyond English
- Offline-first caching and sync
