# todoaw — Flutter Todo App

## Tech Stack
- **Framework:** Flutter 3.x (Dart)
- **State Management:** Riverpod (v2)
- **Local Database:** sqflite (SQLite)
- **Routing:** go_router
- **Notifications:** flutter_local_notifications

## Project Structure
```
lib/
├── core/           # theme, constants, utils, database
├── models/         # Data models (plain Dart)
├── providers/      # Riverpod providers
├── repositories/   # DB operations layer
├── services/       # Notifications, etc.
├── screens/        # Pages (Home, Calendar, Stats, Settings)
├── widgets/        # Reusable UI components
└── main.dart
```

## Conventions
- Plain Dart models with `copyWith` & `toMap`/`fromMap` serialization
- Riverpod `StateNotifier` + `AsyncValue` pattern
- Folder-by-feature for screens
- All strings in `.arb` files for i18n readiness
- Use `dart format` before commits
- All business logic in providers/repositories, not in widgets

## Commands
- `flutter pub get` — install dependencies
- `flutter run` — run app
- `flutter build apk` — build release
- `flutter test` — run tests
- `dart format .` — format code
- `dart analyze` — lint check
