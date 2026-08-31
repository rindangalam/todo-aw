# Todoaw — Aplikasi Todo & Produktivitas

> **Offline-first productivity app for managing tasks, notes, habits, and focus**  
> Complete personal productivity system built with Flutter — all data stored locally on your device.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-2.18-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev/)
[![SQLite](https://img.shields.io/badge/SQLite-Database-003B57?style=flat-square&logo=sqlite&logoColor=white)](https://www.sqlite.org/)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.3-1389FD?style=flat-square)](https://riverpod.dev/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

---

## Overview

**Todoaw** is a full-featured, offline-first productivity application designed to help you organize daily tasks, capture ideas, track habits, and maintain focus — all while keeping your data completely private and stored locally on your device. Built specifically for Indonesian users with Bahasa Indonesia as a first-class citizen.

### Core Philosophy
- **Offline-first**: No internet required, all data stays on your device
- **Privacy-first**: Zero data collection, no cloud sync
- **Calm productivity**: No aggressive notifications or stress-inducing features
- **Culturally relevant**: Designed for Indonesian work culture and language
- **Free forever**: Open source, no subscriptions or premium features

---

## Features

### Task Management

#### Comprehensive Task System
- **CRUD operations** - Create, edit, complete, delete tasks easily
- **Priority levels** - P1 (Urgent), P2 (High), P3 (Medium), P4 (Low)
- **Categories & Tags** - Organize with color-coded categories and custom labels
- **Subtasks** - Nested subtasks (max 2 levels deep)
- **Recurring tasks** - Daily, weekday, weekly, monthly, yearly with custom intervals
- **Task templates** - Save tasks as reusable templates
- **Batch operations** - Multi-select to complete, archive, or delete (long-press)
- **Deadlines & Reminders** - Set due dates with notification reminders (5/15/30/60 min before)
- **Archive & Trash** - Archive completed tasks; deleted tasks auto-purge after 30 days

### Notes

- **CRUD notes** with title and content
- **Color coding** - 6 color options for visual organization
- **Pin notes** - Pinned notes appear at top of grid
- **Inline search** - Real-time search within Notes screen

### Habit Tracker

- **CRUD habits** with daily/weekly/monthly targets
- **Daily logging** - Check off habits each day
- **Streak tracking** - Visualize consistency with streak counter
- **Progress visualization**

### ⏱ Focus Timer (Pomodoro)

- **Preset timers** - 15, 25, 30, 50 minute sessions
- **Ring animation** showing time progress
- **Session history** - Track total focus minutes today
- **Haptic feedback & notifications** when session completes

### Dashboard & Statistics

- **Progress ring** - Daily task completion percentage
- **Weekly bar chart** - Tasks completed per day (Monday-Sunday)
- **Stat cards** - Active Tasks, Completed Tasks, Total Tasks
- **Streak indicator** - Fire  emoji showing consistent productivity

### Calendar

- **Monthly view** with prev/next navigation
- **Color dots** on dates with scheduled tasks
- **Daily agenda** - Task list for selected date
- **"Today" button** - Quick return to current date

### Search & Filter

- **Real-time search** - Find tasks & notes as you type
- **Filter sheet** - Filter by priority, category, tag, completion status, archived

### Theming & Customization

#### Theme Modes
- System (follow device theme)
- Light mode
- Dark mode

#### Accent Color Picker
- **Palette mode** - 91 predefined colors
- **Material mode** - 54 Material Design colors
- **Custom mode** - HSV color slider for unlimited colors
- **Auto-save** - Theme preferences persist across app restarts

### Onboarding & Tours

- **Intro slides** - 3-page introduction on first launch
- **Coach mark tours** - Interactive guides on Home & Notes screens
- **Reset tours** - Re-enable tours from Settings

### Data Export/Import

#### Export Options
- **JSON export** - Complete backup of all data
- **CSV export** - Task data in spreadsheet format
- **SQLite export** - Raw database file
- **Excel export** - Formatted spreadsheet (.xlsx)

#### Import Options
- **JSON import** - Restore from backup
- **Seed data** - Load sample data to try features

### Notifications & Widgets

- **Task reminder notifications** based on set deadlines
- **Focus session completion notifications**
- **Android Home Widgets** - View task summary on home screen
  - Compact widget
  - List widget

---

## Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.x** | Cross-platform UI framework |
| **Dart 2.18+** | Programming language |
| **Riverpod v2** | State management |
| **sqflite** | Local SQLite database |
| **go_router** | Routing & navigation |
| **flutter_local_notifications** | Local push notifications |
| **tutorial_coach_mark** | Interactive onboarding tours |
| **home_widget** | Android home screen widgets |
| **shared_preferences** | User preferences storage |
| **google_fonts** | Custom typography |
| **intl** | Date & number formatting (localized) |
| **uuid** | Unique ID generation |

---

## Installation

### For End Users (Android)

1. **Download APK** - `todoaw.apk` from this repository
2. **Enable installation** from unknown sources (Settings → Security)
3. **Install APK** - Open the file and tap Install
4. **Launch Todoaw** from home screen

#### System Requirements
- Android 5.0 (API 21) or newer
- ~50 MB storage space
- No internet connection required

### For Developers

#### Prerequisites
- Flutter SDK 3.x
- Dart SDK 2.18+
- Android Studio / VS Code
- Android device or emulator

#### Setup

```bash
# Clone repository
git clone https://github.com/rindangalam/todo-aw.git
cd todo-aw

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build apk --release

# Build split APKs (smaller size)
flutter build apk --release --split-per-abi
```

---

## Project Structure

```
todo-aw/
 lib/
    core/
       database/          # SQLite database layer
       models/            # Data models
       providers/         # Riverpod providers
       router/            # go_router configuration
       utils/             # Helper functions
    features/
       tasks/             # Task management
       notes/             # Notes feature
       habits/            # Habit tracking
       focus/             # Focus timer (Pomodoro)
       calendar/          # Calendar view
       dashboard/         # Statistics dashboard
       settings/          # App settings
       onboarding/        # Intro & tours
    shared/
       widgets/           # Reusable widgets
       theme/             # Theme configuration
    main.dart              # App entry point
 assets/
    icon/                  # App icons
 android/                   # Android platform code
 ios/                       # iOS platform code (future)
 web/                       # Web platform code (future)
 test/                      # Unit tests
 integration_test/          # Integration tests
 PRODUCT_BIBLE.md           # Complete product documentation
 PRODUCT_AUDIT.md           # Product audit checklist
 pubspec.yaml               # Flutter dependencies
 README.md
```

---

## Database Schema

### Core Tables
- `tasks` - Task records with metadata
- `subtasks` - Nested subtasks
- `categories` - Task categories
- `tags` - Task tags/labels
- `notes` - Note records
- `habits` - Habit definitions
- `habit_logs` - Daily habit check-ins
- `focus_sessions` - Pomodoro session history
- `task_templates` - Reusable task templates
- `recurring_tasks` - Recurring task patterns

---

## Design Language

### Color System
- **Primary colors**: Based on user-selected accent color
- **Semantic colors**: Success (green), Warning (yellow), Error (red)
- **Category colors**: 6 predefined category colors
- **Note colors**: 6 color options for notes

### Typography
- Google Fonts integration
- Clear hierarchy (H1-H6)
- Readable body text (16sp)
- Accessibility-friendly contrast

### Component Design
- Material Design 3 principles
- Rounded corners (8-16px)
- Consistent spacing (8px grid)
- Touch target minimum 48x48dp

---

## Localization

### Currently Supported
- **Bahasa Indonesia** (primary language)

### Design for Future Localization
- All strings externalized
- Date/time formatting via `intl`
- Number formatting localized
- RTL support ready (not implemented)

---

## Privacy & Security

### Privacy-First Principles
- **100% offline** - No data sent to any server
- **Local storage only** - All data in SQLite on device
- **No analytics** - Zero tracking or telemetry
- **No accounts** - No login or registration required
- **Open source** - Transparent, auditable code

### Data Safety
-  **Data loss warning**: Clearing app data or uninstalling will delete all data
-  **Backup recommended**: Use Export feature regularly
-  **Device-only**: Data never leaves your device

---

## 🧪 Testing

### Unit Tests

```bash
flutter test
```

### Integration Tests

```bash
flutter test integration_test/
```

### Test Coverage
- Core database operations
- Task CRUD operations
- Habit logging
- Recurring task generation
- Export/import functionality

---

## Build & Release

### Android APK

```bash
# Debug build
flutter build apk --debug

# Release build (universal APK)
flutter build apk --release

# Release build (split per ABI - smaller size)
flutter build apk --release --split-per-abi
```

Output: `build/app/outputs/flutter-apk/`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### Generate App Icon

```bash
flutter pub run flutter_launcher_icons:main
```

---

## Performance Standards

- **App startup**: < 2 seconds (cold start)
- **Screen transitions**: 60 FPS animations
- **Database queries**: < 100ms for standard queries
- **Search**: Real-time (< 50ms debounce)
- **Memory usage**: < 100 MB typical
- **APK size**: < 30 MB (split APK)

---

## Product Vision

### Mission
1. Become the #1 task manager in Indonesia
2. Prove that open source can compete with commercial products
3. Build "Calm Productivity" culture

### Values
- **Local-first**: Indonesian language and culture
- **Calm**: No aggressive notifications or stress
- **Private**: Your data belongs to you
- **Free**: No premium features or subscriptions
- **Accessible**: Simple enough for anyone

---

## Roadmap

### Completed (v1.0)
- Task management with priorities and categories
- Notes with color coding
- Habit tracker with streaks
- Focus timer (Pomodoro)
- Dashboard with statistics
- Calendar view
- Export/import functionality
- Android home widgets
- Dark/light theme with custom colors
- Onboarding & tours

### Planned Features
- iOS support
- Web version (PWA)
- Desktop apps (Windows, macOS, Linux)
- Cloud sync (optional, end-to-end encrypted)
- Collaboration features
- Voice notes
- File attachments
- Advanced recurring patterns
- Custom widget layouts

---

## 🤝 Contributing

Contributions are welcome! This is an open source project.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter style guide
- Write tests for new features
- Update documentation
- Keep commits atomic and descriptive

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Author

**Rindang Alam Nur Muhammad**  
GitHub: [@rindangalam](https://github.com/rindangalam)

---

## Acknowledgments

Built with:
- [Flutter](https://flutter.dev/) - Cross-platform framework
- [Riverpod](https://riverpod.dev/) - State management
- [sqflite](https://pub.dev/packages/sqflite) - SQLite plugin
- [go_router](https://pub.dev/packages/go_router) - Routing solution

---

## Documentation

- **[Product Bible](PRODUCT_BIBLE.md)** - Complete product vision, philosophy, and guidelines
- **[Product Audit](PRODUCT_AUDIT.md)** - Quality assurance checklist

---

## Support

For issues, questions, or feature requests:
- Open an issue on [GitHub Issues](https://github.com/rindangalam/todo-aw/issues)

---

*Atur hidupmu, tanpa ribet. *
