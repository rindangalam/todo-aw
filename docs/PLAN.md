# Execution Plan — todoaw

## Milestone Overview

| Milestone | Focus | Est. Time |
|---|---|---|
| **M1** | Foundation | —
| **M2** | Core Features | —
| **M3** | Time Features | —
| **M4** | Smart Features | —
| **M5** | Polish | —
| **M6** | Release | —

---

## M1 — Foundation

- [ ] `flutter create todoaw` with org name
- [ ] Setup folder structure per AGENTS.md
- [ ] Add dependencies to `pubspec.yaml` (riverpod, isar, go_router, freezed, flutter_local_notifications, etc.)
- [ ] Configure theme system (light + dark tokens from PRD)
- [ ] Setup go_router with `StatefulShellRoute` + 4 bottom tabs
- [ ] Create Isar schema: `Task` and `Category` models with freezed
- [ ] Create base repository pattern + DI setup

## M2 — Core Features

- [ ] Home screen: task list grouped by date (Today/Tomorrow/Upcoming)
- [ ] Sticky header per date group
- [ ] Task card widget (checkbox, category dot, title, priority badge, due date)
- [ ] Create task screen (title, description, priority, category, due date)
- [ ] Edit task screen (reuse create form with prefill)
- [ ] Task detail screen with subtask list
- [ ] Add subtask from task detail
- [ ] Priority selector widget
- [ ] Category CRUD screen (manage categories)
- [ ] Swipe to complete (left) and delete (right) with haptic feedback
- [ ] Empty state widget with illustration

## M3 — Time Features

- [ ] Date picker widget (integrated with task form)
- [ ] Due date display on task cards (relative: "Today", "Tomorrow", "In 3d")
- [ ] Recurring task screen (frequency picker + RRULE builder)
- [ ] Recurring task logic: generate next instance on completion
- [ ] Calendar screen: monthly grid, dots on dates with tasks
- [ ] Tap date on calendar → show daily task list
- [ ] Notification service setup
- [ ] Schedule local notification on task save (due date - 30min default)
- [ ] Cancel/reschedule notification on task update/delete

## M4 — Smart Features

- [ ] Full-text search bar (debounced, search on title + description)
- [ ] Search results with highlight
- [ ] Filter bottom sheet: status, priority, category, date range
- [ ] Filter chips on home screen
- [ ] Archive task (move to archive, hide from main list)
- [ ] Trash screen: list recently deleted tasks
- [ ] Restore from trash
- [ ] Permanent delete with confirmation dialog
- [ ] Auto-purge trash (tasks with `deletedAt` > 30 days)

## M5 — Polish

- [x] Stats screen: completion rate (pie chart)
- [x] Streak counter (consecutive days with at least 1 completion)
- [x] Tasks completed per day (bar chart, last 7/30 days)
- [x] Dark mode toggle in settings (system/manual)
- [x] List animations: staggered fade-in, slide, reorder
- [x] Hero transitions: task card → detail screen
- [x] Splash screen (flutter_native_splash config ready, Dart splash widget)
- [x] App icon (adaptive icon — config ready in pubspec, needs `assets/icon/app_icon.png`)

## M6 — Release

- [x] Unit tests: models (48 tests) — task, category, recurrence, filter_state
- [x] Unit tests: repositories (28 tests) — task_repo, category_repo
- [x] Unit tests: providers (25 tests) — task_list, category, filter, search, theme, stats
- [x] Unit tests: services (24 tests) — notification, recurring_task
- [x] Widget tests (screen-level) — home, task_form, calendar, search
- [x] `dart analyze` — zero warnings
- [x] `dart format .` — clean formatting
- [ ] Integration test: create task → complete task flow (not yet written, needs device to run)
- [ ] Integration test: create → search → edit flow (not yet written, needs device to run)
- [ ] Integration test: delete → restore from trash flow (not yet written, needs device to run)
- [x] Build APK (release) — size 19.7MB (target < 15MB, needs optimization)
- [ ] Build AAB (release) for Play Store
- [ ] Play Store listing assets: feature graphic, screenshots (EN + ID)

---

## Testing Strategy

| Layer | Type | Tools | Target Coverage |
|---|---|---|---|
| Models | Unit | `flutter_test` | 100% |
| Repositories | Unit | `flutter_test` + mock Isar | 90%+ |
| Providers | Unit | `riverpod` test utilities | 90%+ |
| Screens | Widget | `flutter_test` + `ProviderScope` | 80%+ |
| Services | Unit | `flutter_test` | 90%+ |
| Integration | Integration | `integration_test` | 3 critical flows |

### Test File Structure

```
test/
├── models/
│   ├── task_test.dart
│   └── category_test.dart
├── repositories/
│   ├── task_repository_test.dart
│   └── category_repository_test.dart
├── providers/
│   ├── task_list_provider_test.dart
│   ├── task_form_provider_test.dart
│   └── filter_provider_test.dart
├── screens/
│   ├── home_screen_test.dart
│   ├── task_form_screen_test.dart
│   ├── calendar_screen_test.dart
│   └── search_screen_test.dart
├── services/
│   ├── notification_service_test.dart
│   └── recurring_task_service_test.dart
└── integration/
    └── critical_flows_test.dart
```

---

## Release Criteria

| Criteria | Target | Verification |
|---|---|---|
| Min SDK | Android 5.0 (API 21) | Check `build.gradle` |
| Target SDK | Android 34 | Check `build.gradle` |
| iOS target | iOS 13.0 | Check Podfile |
| APK size | < 15 MB (release) | `flutter build apk` + check filesize |
| App startup | < 2s on mid-range | Manual measure |
| Crash rate | < 0.1% | — |
| Test pass | 100% | `flutter test` |
| Lint | 0 warnings | `dart analyze` |
| Format | clean | `dart format --dry-run .` |

---

## Progress

- **M1:** ✅✅✅✅✅✅✅ (7/7)
- **M2:** ✅✅✅✅✅✅✅✅✅✅✅✅ (12/12)
- **M3:** ✅✅✅✅✅✅✅✅✅ (9/9)
- **M4:** ✅✅✅✅✅✅✅ (7/7)
- **M5:** ✅✅✅✅✅✅✅✅ (8/8)
- **M6:** ✅✅✅✅✅✅✅✅⬜⬜⬜⬜ (8/12)
