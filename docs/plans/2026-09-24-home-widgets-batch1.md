# Home Widgets Batch 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bangun 7 widget home screen Android Todoaw (Today, Dashboard, Compact, Priority, Quick Add, Notes Today, Quick Note) dari nol dengan `home_widget` + RemoteViews, full interaktif, theme light/dark/accent.

**Architecture:** Dart `WidgetBridge` satu-satunya source of query â†’ push payload ke SharedPreferences via `home_widget` â†’ 7 `HomeWidgetProvider` Kotlin render RemoteViews. Aksi: broadcast toggle (Dart receiver), `QuickInputActivity` overlay + MethodChannel, deep link ke `MainActivity`/go_router. Refresh: on-change, lifecycle, WorkManager 30 menit.

**Tech Stack:** Flutter/Riverpod, `home_widget`, `workmanager`, Kotlin AppWidget/RemoteViews, MethodChannel, in-repo `flutter test`.

**Spec:** `docs/specs/2026-09-24-home-widgets-batch1-design.md` (approved)

---

## File structure

| Path | Action | Responsibility |
|---|---|---|
| `pubspec.yaml` | Edit | + `home_widget`, `workmanager` |
| `lib/services/widget_bridge.dart` | Create | Payload builder + `updateAll()` + theme resolve |
| `lib/services/widget_actions.dart` | Create | Action string constants + `PendingWidgetAction` |
| `lib/services/widget_quick_input_channel.dart` | Create | MethodChannel handler `saveQuick` |
| `lib/services/widget_receiver.dart` | Create | home_widget background/receiver callbacks |
| `lib/main.dart` | Edit | Init receiver, WorkManager, lifecycle, app-open refresh |
| `lib/presentation/screens/home_screen.dart` | Edit | Handle widget deep-link actions |
| `lib/providers/task_list_provider.dart` | Edit | `WidgetBridge.updateAll()` after CRUD/toggle |
| `lib/providers/note_provider.dart` | Edit | Same after note CRUD |
| `lib/providers/theme_provider.dart` | Edit | Push theme on mode/accent change |
| `android/.../widget/WidgetTheme.kt` | Create | parseColor + apply palette to RemoteViews |
| `android/.../widget/WidgetData.kt` | Create | Read prefs JSON â†’ models |
| `android/.../widget/BaseWidgetProvider.kt` | Create | Safe onUpdate, empty fallback, intent helpers |
| `android/.../widget/TodayWidget.kt` â€¦ (7) | Create | One provider per widget |
| `android/.../widget/QuickInputActivity.kt` | Create | Translucent overlay input |
| `android/.../widget/WidgetActionReceiver.kt` | Create | Forward toggle broadcast to Dart |
| `android/.../MainActivity.kt` | Edit | Handle widget intents â†’ Flutter |
| `android/.../res/layout/widget_*.xml` | Create Ã—8 | 7 layouts + quick input |
| `android/.../res/xml/widget_*_info.xml` | Create Ã—7 | AppWidget provider info |
| `android/.../res/drawable/*` | Create | checkbox, ring, icons as needed |
| `android/.../res/values/styles.xml` | Edit | QuickInput translucent theme (if missing) |
| `AndroidManifest.xml` | Edit | 7 receivers + activity + action receiver |
| `test/services/widget_bridge_test.dart` | Create | Payload builder unit tests |

**Package Kotlin:** semua file widget di `com.todoaw.todoaw.widget` â€” **bukan** root package (beda dari kode lama).

---

## Task outline

1. Dependencies + `WidgetActions` + payload builder TDD  
2. `WidgetBridge.updateAll()` + theme resolve + unit tests  
3. Kotlin base: `WidgetTheme`, `WidgetData`, `BaseWidgetProvider` + manifest skeleton  
4. **Today widget** end-to-end (checkpoint device)  
5. Compact + Priority  
6. Dashboard  
7. QuickInput Activity + Channel + Quick Add + Quick Note (checkpoint)  
8. Notes Today  
9. Deep-link routing di home_screen + hooks providers + lifecycle  
10. WorkManager periodic  
11. Theme light/dark/accent full + hardening  
12. Manual device checklist (user)

---

## Task 1: Dependencies + WidgetActions

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/services/widget_actions.dart`
- Test: `test/services/widget_bridge_test.dart` (created empty structure for later tasks â€” first failing test lives in Task 2)

- [ ] **Step 1: Add dependencies**

Edit `pubspec.yaml` â€” under `dependencies:` after `shared_preferences`:

```yaml
  # Home widgets
  home_widget: ^0.14.0
  workmanager: ^0.5.2
```

- [ ] **Step 2: Run pub get**

Run: `flutter pub get`  
Expected: `Changed N dependencies` (or already up to date), no errors. If version resolution fails, pin nearest stable that resolves and note it in commit message.

- [ ] **Step 3: Create `lib/services/widget_actions.dart`**

```dart
/// Widget action strings shared by bridge, receivers, and UI.
class WidgetActions {
  WidgetActions._();

  static const openHome = 'open_home';
  static const openNotes = 'open_notes';
  static const openDashboard = 'open_dashboard';
  static const openTasksPriority = 'open_tasks_priority';
  static const openTask = 'open_task';
  static const openNote = 'open_note';
  static const toggleTask = 'toggle_task';
  static const newTask = 'new_task';
  static const newNote = 'new_note';
}

/// One-shot action payload set by home_widget click/receiver before UI handles it.
class PendingWidgetAction {
  static String? action;
  static String? taskUuid;
  static String? noteUuid;

  static void clear() {
    action = null;
    taskUuid = null;
    noteUuid = null;
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/services/widget_actions.dart
git commit -m "feat(widgets): add home_widget + workmanager deps and action constants"
```

---

## Task 2: Payload builder (TDD)

**Files:**
- Create: `lib/services/widget_bridge.dart` (builder sections first)
- Create: `test/services/widget_bridge_test.dart`

- [ ] **Step 1: Write failing tests for payload selection rules**

Create `test/services/widget_bridge_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/models/note.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/services/widget_bridge.dart';

Task task({
  required String uuid,
  required String title,
  Priority priority = Priority.p3,
  DateTime? dueDate,
  bool isCompleted = false,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return Task(
    uuid: uuid,
    title: title,
    priority: priority,
    dueDate: dueDate,
    isCompleted: isCompleted,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

Note note({
  required String uuid,
  required String title,
  String? content,
  bool isPinned = false,
  bool isArchived = false,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return Note(
    uuid: uuid,
    title: title,
    content: content,
    isPinned: isPinned,
    isArchived: isArchived,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);

  group('todayTasks', () {
    test('includes only dueDate on local today (not overdue)', () {
      final tasks = [
        task(
          uuid: 'a',
          title: 'Today',
          dueDate: startOfToday.add(const Duration(hours: 9)),
        ),
        task(
          uuid: 'b',
          title: 'Overdue',
          dueDate: startOfToday.subtract(const Duration(days: 1)),
        ),
        task(uuid: 'c', title: 'No due'),
      ];
      final result = WidgetBridge.todayTasks(tasks, startOfToday);
      expect(result.map((t) => t.uuid), ['a']);
    });

    test('progress: completed/total, zero total â†’ 0', () {
      final empty = WidgetBridge.progressFor([], startOfToday);
      expect(empty, 0);
      final tasks = [
        task(uuid: 'a', title: 'x', isCompleted: true,
            dueDate: startOfToday.add(const Duration(hours: 1))),
        task(uuid: 'b', title: 'y', dueDate: startOfToday.add(const Duration(hours: 2))),
      ];
      expect(WidgetBridge.progressFor(tasks, startOfToday), 50);
    });
  });

  group('priorityTasks', () {
    test('only P1 and P2, pending, P1 first', () {
      final tasks = [
        task(uuid: 'p2', title: 'Med', priority: Priority.p2),
        task(uuid: 'p3', title: 'Low', priority: Priority.p3),
        task(uuid: 'p1', title: 'High', priority: Priority.p1),
        task(uuid: 'done', title: 'Done', priority: Priority.p1, isCompleted: true),
      ];
      final result = WidgetBridge.priorityTasks(tasks);
      expect(result.map((t) => t.uuid), ['p1', 'p2']);
      expect(WidgetBridge.priorityLevel(result.first), 'high');
      expect(WidgetBridge.priorityLevel(result.last), 'medium');
    });
  });

  group('nextTask', () {
    test('future dueDate wins over no-due', () {
      final tasks = [
        task(uuid: 'nodue', title: 'A', createdAt: today),
        task(
          uuid: 'future',
          title: 'B',
          dueDate: today.add(const Duration(hours: 2)),
        ),
      ];
      expect(WidgetBridge.nextTask(tasks)?.uuid, 'future');
    });
  });

  group('notesToday', () {
    test('active notes with created/updated today, pin first', () {
      final notes = [
        note(uuid: 'n1', title: 'Old pin', isPinned: true,
            createdAt: today.subtract(const Duration(days: 2)),
            updatedAt: today.subtract(const Duration(days: 2))),
        note(uuid: 'n2', title: 'Created now',
            createdAt: startOfToday.add(const Duration(hours: 10))),
        note(uuid: 'n3', title: 'Archived', isArchived: true,
            createdAt: startOfToday),
      ];
      final result = WidgetBridge.notesToday(notes, startOfToday);
      expect(result.map((n) => n.uuid), ['n1', 'n2']);
      expect(WidgetBridge.notePreview(result.first.content), '');
    });

    test('notePreview truncates to one line', () {
      expect(WidgetBridge.notePreview(null), '');
      expect(WidgetBridge.notePreview('Line1\nLine2'), 'Line1');
      expect(WidgetBridge.notePreview('abc'), 'abc');
    });
  });

  group('theme palette', () {
    test('dark and light palettes have ARGB hex strings', () {
      final dark = WidgetBridge.paletteHex(isDark: true, accent: 0xFF3B82F6);
      final light = WidgetBridge.paletteHex(isDark: false, accent: 0xFF3B82F6);
      expect(dark['bgColor'], 'FF0F1729');
      expect(light['bgColor'], 'FFF8FAFC');
      expect(dark['accentColor'], 'FF3B82F6');
      expect(light['textColor'], 'FF0F172A');
      for (final v in dark.values) {
        expect(RegExp(r'^[0-9A-Fa-f]{8}$').hasMatch(v), isTrue);
      }
    });
  });
}
```

- [ ] **Step 2: Run tests â€” expect FAIL (compile error)**

Run: `flutter test test/services/widget_bridge_test.dart`  
Expected: FAIL â€” `WidgetBridge` undefined.

- [ ] **Step 3: Create `widget_bridge.dart` skeleton with pure helpers**

Create `lib/services/widget_bridge.dart`:

```dart
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../data/models/note.dart';
import '../data/models/task.dart';
import '../data/repositories/note_repository.dart';
import '../data/repositories/task_repository.dart';
import 'widget_actions.dart';

const String kWidgetPackageName = 'com.todoaw.todoaw';

/// Pure selection/transform helpers (unit-tested). Side-effect free.
class WidgetBridge {
  WidgetBridge._();

  static const int schemaVersion = 1;

  static const List<String> widgetClassNames = [
    '$kWidgetPackageName.widget.TodayWidget',
    '$kWidgetPackageName.widget.DashboardWidget',
    '$kWidgetPackageName.widget.CompactWidget',
    '$kWidgetPackageName.widget.PriorityWidget',
    '$kWidgetPackageName.widget.QuickAddWidget',
    '$kWidgetPackageName.widget.NotesTodayWidget',
    '$kWidgetPackageName.widget.QuickNoteWidget',
  ];

  static DateTime startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      startOfDay(a) == startOfDay(b);

  static String formatTime(DateTime? t) {
    if (t == null) return '';
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  static List<Task> todayTasks(List<Task> all, DateTime day) {
    final s = startOfDay(day);
    return all.where((t) {
      if (t.isCompleted) return false;
      if (t.dueDate == null) return false;
      return startOfDay(t.dueDate!) == s;
    }).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  /// Includes completed for progress denominator.
  static List<Task> todayScope(List<Task> all, DateTime day) {
    final s = startOfDay(day);
    return all.where((t) {
      if (t.dueDate == null) return false;
      return startOfDay(t.dueDate!) == s;
    }).toList();
  }

  static int progressFor(List<Task> all, DateTime day) {
    final scope = todayScope(all, day);
    if (scope.isEmpty) return 0;
    final done = scope.where((t) => t.isCompleted).length;
    return (done * 100 / scope.round()).round();
  }

  static List<Task> priorityTasks(List<Task> all) {
    final list = all
        .where((t) =>
            !t.isCompleted &&
            !t.isArchived &&
            t.deletedAt == null &&
            (t.priority == Priority.p1 || t.priority == Priority.p2))
        .toList();
    list.sort((a, b) {
      final pa = a.priority == Priority.p1 ? 0 : 1;
      final pb = b.priority == Priority.p1 ? 0 : 1;
      if (pa != pb) return pa - pb;
      final da = a.dueDate;
      final db = b.dueDate;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return list;
  }

  static String priorityLevel(Task t) =>
      t.priority == Priority.p1 ? 'high' : 'medium';

  static Task? nextTask(List<Task> all) {
    final pending = all
        .where((t) =>
            !t.isCompleted && !t.isArchived && t.deletedAt == null)
        .toList();
    final now = DateTime.now();
    final future = pending.where((t) => t.dueDate != null && t.dueDate!.isAfter(now)).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    if (future.isNotEmpty) return future.first;
    final noDue = pending.where((t) => t.dueDate == null).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return noDue.isNotEmpty ? noDue.first : null;
  }

  static List<Note> notesToday(List<Note> all, DateTime day) {
    final s = startOfDay(day);
    final list = all.where((n) {
      if (n.isArchived) return false;
      return isSameDay(n.createdAt, s) || isSameDay(n.updatedAt, s);
    }).toList();
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  static String notePreview(String? content) {
    if (content == null || content.trim().isEmpty) return '';
    final line = content.trim().split('\n').first.trim();
    return line;
  }

  static String greeting(DateTime now) {
    final h = now.hour;
    if (h < 11) return 'Selamat Pagi';
    if (h < 15) return 'Selamat Siang';
    if (h < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  static String dateLabel(DateTime now) {
    try {
      return DateFormat('EEE, d MMM').format(now);
    } catch (_) {
      return '${now.day}/${now.month}/${now.year}';
    }
  }

  static Map<String, String> paletteHex({
    required bool isDark,
    required int accent,
  }) {
    String hex(int argb) =>
        argb.toRadixString(16).toUpperCase().padLeft(8, '0');
    final accentHex = hex(accent);
    if (isDark) {
      return {
        'bgColor': hex(0xFF0F1729),
        'cardBgColor': hex(0xFF1A2540),
        'accentColor': accentHex,
        'textColor': hex(0xFFFFFFFF),
        'mutedColor': hex(0xFF94A3B8),
        'borderColor': hex(0xFF1E293B),
        'dangerColor': hex(0xFFEF4444),
        'warnColor': hex(0xFFF59E0B),
        'successColor': hex(0xFF10B981),
      };
    }
    return {
      'bgColor': hex(0xFFF8FAFC),
      'cardBgColor': hex(0xFFFFFFFF),
      'accentColor': accentHex,
      'textColor': hex(0xFF0F172A),
      'mutedColor': hex(0xFF64748B),
      'borderColor': hex(0xFFE2E8F0),
      'dangerColor': hex(0xFFEF4444),
      'warnColor': hex(0xFFF59E0B),
      'successColor': hex(0xFF10B981),
    };
  }

  /// Build all SharedPreferences key/values (pure â€” for tests + updateAll).
  static Future<Map<String, String>> buildPayload({
    required bool isDark,
    required int accent,
    TaskRepository? taskRepo,
    NoteRepository? noteRepo,
    DateTime? nowOverride,
  }) async {
    final now = nowOverride ?? DateTime.now();
    final tasks = await (taskRepo ?? TaskRepository()).getAll();
    final notes = await (noteRepo ?? NoteRepository()).getAll();
    final day = startOfDay(now);

    final todayPending = todayTasks(tasks, day);
    final scope = todayScope(tasks, day);
    final completed = scope.where((t) => t.isCompleted).length;
    final priorities = priorityTasks(tasks).take(5).toList();
    final next = nextTask(tasks);
    final todayNotes = notesToday(notes, day).take(4).toList();

    final todayTaskJson = jsonEncode(todayPending.take(5).map((t) => {
          'uuid': t.uuid,
          'title': t.title,
          'time': formatTime(t.dueDate),
          'done': t.isCompleted,
        }).toList());

    final priorityJson = jsonEncode(priorities.map((t) => {
          'uuid': t.uuid,
          'title': t.title,
          'time': formatTime(t.dueDate),
          'level': priorityLevel(t),
        }).toList());

    final notesJson = jsonEncode(todayNotes.map((n) => {
          'uuid': n.uuid,
          'title': n.title,
          'preview': notePreview(n.content),
          'time': n.updatedAt.isAfter(n.createdAt)
              ? formatTime(n.updatedAt)
              : formatTime(n.createdAt),
          'pinned': n.isPinned,
        }).toList());

    final progress =
        scope.isEmpty ? 0 : (completed * 100 / scope.length).round();
    final notesActiveToday = todayNotes.length;

    final payload = <String, String>{
      'schemaVersion': '$schemaVersion',
      'themeMode': isDark ? 'dark' : 'light',
      'progress': '$progress',
      'completedCount': '$completed',
      'totalCount': '${scope.length}',
      'todayTaskList': todayTaskJson,
      'priorityTaskList': priorityJson,
      'notesTodayList': notesJson,
      'notesTodayCount': '$notesActiveToday',
      'tasksTodayCount':
          '${todayPending.length}',
      'totalTodayCount': '${scope.length}',
      'nextTaskTitle': next?.title ?? '',
      'nextTaskTime': formatTime(next?.dueDate),
      'nextTaskUuid': next?.uuid ?? '',
      'greeting': greeting(now),
      'dateLabel': dateLabel(now),
      'hasTodayTasks': todayPending.isEmpty ? '0' : '1',
      'hasPriorityTasks': priorities.isEmpty ? '0' : '1',
      'hasNotesToday': todayNotes.isEmpty ? '0' : '1',
    };
    payload.addAll(paletteHex(isDark: isDark, accent: accent));
    return payload;
  }
}
```

- [ ] **Step 4: Run tests â€” expect PASS**

Run: `flutter test test/services/widget_bridge_test.dart`  
Expected: All PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/services/widget_bridge.dart test/services/widget_bridge_test.dart
git commit -m "feat(widgets): pure payload builder + domain rules with unit tests"
```

---

## Task 3: updateAll + theme push + lifecycle hooks (minimal)

**Files:**
- Modify: `lib/services/widget_bridge.dart` (append side-effect methods)
- Modify: `lib/main.dart`
- Modify: `lib/providers/theme_provider.dart`

- [ ] **Step 1: Append `updateAll` + repository load helpers to WidgetBridge**

Edit `lib/services/widget_bridge.dart` — add imports if needed (`shared_preferences` not required here; theme from callers) and after `buildPayload`:

```dart
  /// Resolve dark from ThemeMode + platform brightness.
  static bool resolveIsDark(ThemeMode mode, Brightness platformBrightness) {
    switch (mode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return platformBrightness == Brightness.dark;
    }
  }

  static Future<void> updateAll({
    required ThemeMode themeMode,
    required int accentColor,
    Brightness platformBrightness = Brightness.light,
  }) async {
    try {
      final isDark = resolveIsDark(themeMode, platformBrightness);
      final payload = await buildPayload(isDark: isDark, accent: accentColor);
      for (final entry in payload.entries) {
        await HomeWidget.saveWidgetData(entry.key, entry.value);
      }
      for (final name in widgetClassNames) {
        await HomeWidget.updateWidget(qualifiedAndroidName: name);
      }
    } catch (e, st) {
      debugPrint('[WidgetBridge] updateAll failed: $e\n$st');
    }
  }
}
```

Note: keep `ThemeMode` import — add `import 'package:flutter/material.dart';` replacing widgets import if needed.

- [ ] **Step 2: Wire main() app-open refresh (after DB init, non-web)**

Edit `lib/main.dart` — after `AppDatabase.init()` and SharedPreferences init, before `runApp`:

```dart
  // Push home widget snapshot once app is ready (Android only).
  if (!kIsWeb) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString('theme_mode') ?? 'system';
      final mode = ThemeMode.values.firstWhere(
        (m) => m.name == modeStr,
        orElse: () => ThemeMode.system,
      );
      final accent = prefs.getInt('accent_color') ?? 0xFF0EA5E9;
      final platformDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
      await WidgetBridge.updateAll(
        themeMode: mode,
        accentColor: accent,
        platformBrightness: platformDark ? Brightness.dark : Brightness.light,
      );
    } catch (_) {}
  }
```

Add imports: `import 'package:flutter/material.dart';` (already), `services/widget_bridge.dart`.

- [ ] **Step 3: Push widget on theme/accent change**

Edit `lib/providers/theme_provider.dart` — in `setMode` after `_save()` and in `AccentColorNotifier.setColor` after `_save()`:

```dart
    unawaited(_pushWidgetTheme());
```

Add helper on both notifiers (or shared top-level):

```dart
Future<void> pushWidgetThemeFromPrefs() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString('theme_mode') ?? 'system';
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == modeStr,
      orElse: () => ThemeMode.system,
    );
    final accent = prefs.getInt('accent_color') ?? 0xFF0EA5E9;
    final platformDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    await WidgetBridge.updateAll(
      themeMode: mode,
      accentColor: accent,
      platformBrightness: platformDark ? Brightness.dark : Brightness.light,
    );
  } catch (_) {}
}
```

Import `dart:async` for `unawaited`, `services/widget_bridge.dart`, `widgets.dart`. Call `unawaited(pushWidgetThemeFromPrefs())` from both setters.

- [ ] **Step 4: Analyzer + tests**

Run: `flutter analyze lib/services/widget_bridge.dart lib/main.dart lib/providers/theme_provider.dart`  
Expected: No errors (warnings pre-existing OK).

Run: `flutter test test/services/widget_bridge_test.dart`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/services/widget_bridge.dart lib/main.dart lib/providers/theme_provider.dart
git commit -m "feat(widgets): WidgetBridge.updateAll + refresh on open and theme change"
```

---

## Task 4: Kotlin base + manifest skeleton + Today layout

**Files:**
- Create: `android/app/src/main/kotlin/com/todoaw/todoaw/widget/WidgetTheme.kt`
- Create: `android/app/src/main/kotlin/com/todoaw/todoaw/widget/WidgetData.kt`
- Create: `android/app/src/main/kotlin/com/todoaw/todoaw/widget/BaseWidgetProvider.kt`
- Create: `android/app/src/main/kotlin/com/todoaw/todoaw/widget/TodayWidget.kt`
- Create: `android/app/src/main/res/layout/widget_today.xml`
- Create: `android/app/src/main/res/xml/widget_today_info.xml`
- Create: `android/app/src/main/res/drawable/widget_checkbox_done.xml`
- Create: `android/app/src/main/res/drawable/widget_checkbox_todo.xml`
- Create: `android/app/src/main/res/drawable/widget_bg_rounded.xml`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Create drawables**

`widget_checkbox_done.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#3B82F6" />
    <corners android:radius="4dp" />
    <size android:width="14dp" android:height="14dp" />
</shape>
```

`widget_checkbox_todo.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#00000000" />
    <stroke android:width="1.5dp" android:color="#64748B" />
    <corners android:radius="4dp" />
    <size android:width="14dp" android:height="14dp" />
</shape>
```

`widget_bg_rounded.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#0F1729" />
    <corners android:radius="16dp" />
</shape>
```

- [ ] **Step 2: WidgetTheme.kt**

`android/app/src/main/kotlin/com/todoaw/todoaw/widget/WidgetTheme.kt`:

```kotlin
package com.todoaw.todoaw.widget

import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews

data class WidgetPalette(
    val bg: Int,
    val card: Int,
    val accent: Int,
    val text: Int,
    val muted: Int,
    val border: Int,
    val danger: Int,
    val warn: Int,
    val success: Int,
    val isDark: Boolean,
)

object WidgetTheme {
    fun parseColor(hex: String?, default: Int): Int {
        if (hex.isNullOrBlank()) return default
        return try {
            val clean = hex.replace("#", "").replace("0x", "")
            val full = if (clean.length == 6) "FF$clean" else clean
            full.toLong(16).toInt()
        } catch (_: Exception) {
            default
        }
    }

    fun palette(data: SharedPreferences): WidgetPalette {
        val isDark = data.getString("themeMode", "dark") != "light"
        return WidgetPalette(
            bg = parseColor(data.getString("bgColor", null), if (isDark) 0xFF0F1729.toInt() else 0xFFF8FCFC.toInt()),
            card = parseColor(data.getString("cardBgColor", null), if (isDark) 0xFF1A2540.toInt() else 0xFFFFFFFF.toInt()),
            accent = parseColor(data.getString("accentColor", null), 0xFF3B82F6.toInt()),
            text = parseColor(data.getString("textColor", null), if (isDark) 0xFFFFFFFF.toInt() else 0xFF0F172A.toInt()),
            muted = parseColor(data.getString("mutedColor", null), if (isDark) 0xFF94A3B8.toInt() else 0xFF64748B.toInt()),
            border = parseColor(data.getString("borderColor", null), if (isDark) 0xFF1E293B.toInt() else 0xFFE2E8F0.toInt()),
            danger = parseColor(data.getString("dangerColor", null), 0xFFEF4444.toInt()),
            warn = parseColor(data.getString("warnColor", null), 0xFFF59E0B.toInt()),
            success = parseColor(data.getString("successColor", null), 0xFF10B981.toInt()),
            isDark = isDark,
        )
    }

    fun applyRoot(views: RemoteViews, p: WidgetPalette, rootId: Int) {
        views.setInt(rootId, "setBackgroundColor", p.bg)
    }

    fun tintText(views: RemoteViews, id: Int, color: Int) {
        views.setTextColor(id, color)
    }
}
```

- [ ] **Step 3: WidgetData.kt**

`android/app/src/main/kotlin/com/todoaw/todoaw/widget/WidgetData.kt`:

```kotlin
package com.todoaw.todoaw.widget

import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

data class WidgetTaskItem(
    val uuid: String,
    val title: String,
    val time: String,
    val done: Boolean,
    val level: String,
)

data class WidgetNoteItem(
    val uuid: String,
    val title: String,
    val preview: String,
    val time: String,
    val pinned: Boolean,
)

object WidgetData {
    fun schemaOk(data: SharedPreferences): Boolean {
        val v = data.getString("schemaVersion", "1")?.toIntOrNull() ?: 1
        return v == 1
    }

    fun int(data: SharedPreferences, key: String, default: Int = 0): Int =
        data.getString(key, null)?.toIntOrNull() ?: default

    fun str(data: SharedPreferences, key: String): String =
        data.getString(key, null) ?: ""

    fun boolFlag(data: SharedPreferences, key: String): Boolean =
        data.getString(key, "0") == "1"

    private fun parseTaskArray(json: String?): List<WidgetTaskItem> {
        if (json.isNullOrBlank()) return emptyList()
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).mapNotNull { i ->
                val o = arr.optJSONObject(i) ?: return@mapNotNull null
                WidgetTaskItem(
                    uuid = o.optString("uuid"),
                    title = o.optString("title"),
                    time = o.optString("time"),
                    done = o.optBoolean("done", false),
                    level = o.optString("level"),
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun parseNoteArray(json: String?): List<WidgetNoteItem> {
        if (json.isNullOrBlank()) return emptyList()
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).mapNotNull { i ->
                val o = arr.optJSONObject(i) ?: return@mapNotNull null
                WidgetNoteItem(
                    uuid = o.optString("uuid"),
                    title = o.optString("title"),
                    preview = o.optString("preview"),
                    time = o.optString("time"),
                    pinned = o.optBoolean("pinned", false),
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun todayTasks(data: SharedPreferences): List<WidgetTaskItem> =
        parseTaskArray(data.getString("todayTaskList", null))

    fun priorityTasks(data: SharedPreferences): List<WidgetTaskItem> =
        parseTaskArray(data.getString("priorityTaskList", null))

    fun notesToday(data: SharedPreferences): List<WidgetNoteItem> =
        parseNoteArray(data.getString("notesTodayList", null))
}
```

- [ ] **Step 4: BaseWidgetProvider.kt**

`android/app/src/main/kotlin/com/todoaw/todoaw/widget/BaseWidgetProvider.kt`:

```kotlin
package com.todoaw.todoaw.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

abstract class BaseWidgetProvider : HomeWidgetProvider() {
    protected abstract val layoutRes: Int

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, layoutRes)
                render(context, views, widgetData, id)
                appWidgetManager.updateAppWidget(id, views)
            } catch (_: Exception) {
                try {
                    val fallback = RemoteViews(context.packageName, layoutRes)
                    applySafeEmpty(context, fallback, widgetData)
                    appWidgetManager.updateAppWidget(id, fallback)
                } catch (_: Exception) {
                }
            }
        }
    }

    protected abstract fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    )

    protected open fun applySafeEmpty(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, android.R.id.background)
    }

    protected fun activityPending(
        context: Context,
        requestCode: Int,
        action: String,
        extras: Map<String, String> = emptyMap(),
    ): PendingIntent {
        val intent = Intent(context, com.todoaw.todoaw.MainActivity::class.java).apply {
            this.action = action
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            extras.forEach { (k, v) -> putExtra(k, v) }
        }
        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    protected fun activityPendingClass(
        context: Context,
        requestCode: Int,
        target: Class<*>,
        action: String,
        extras: Map<String, String> = emptyMap(),
    ): PendingIntent {
        val intent = Intent(context, target).apply {
            this.action = action
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            extras.forEach { (k, v) -> putExtra(k, v) }
        }
        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    protected fun togglePending(
        context: Context,
        requestCode: Int,
        taskUuid: String,
    ): PendingIntent {
        val intent = Intent(context, WidgetActionReceiver::class.java).apply {
            action = "com.todoaw.todoaw.widget.ACTION_TOGGLE_TASK"
            putExtra("uuid", taskUuid)
        }
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
```

- [ ] **Step 5: widget_today.xml layout**

`android/app/src/main/res/layout/widget_today.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/widget_today_root"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#0F1729"
    android:orientation="vertical"
    android:padding="12dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center_vertical">

        <TextView
            android:id="@+id/widget_today_logo"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="todoaw"
            android:textColor="#FFFFFF"
            android:textSize="13sp"
            android:textStyle="bold" />

        <View
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_weight="1" />

        <TextView
            android:id="@+id/widget_today_date"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="#94A3B8"
            android:textSize="11sp" />
    </LinearLayout>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="6dp"
        android:orientation="horizontal"
        android:gravity="center_vertical">

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical">

            <TextView
                android:id="@+id/widget_today_title"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Today"
                android:textColor="#FFFFFF"
                android:textSize="16sp"
                android:textStyle="bold" />

            <TextView
                android:id="@+id/widget_today_subtitle"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Semangat, kamu bisa!"
                android:textColor="#94A3B8"
                android:textSize="11sp" />
        </LinearLayout>

        <TextView
            android:id="@+id/widget_today_progress_text"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:background="@drawable/widget_checkbox_done"
            android:gravity="center"
            android:minWidth="44dp"
            android:paddingHorizontal="8dp"
            android:paddingVertical="6dp"
            android:text="0/0"
            android:textColor="#FFFFFF"
            android:textSize="11sp"
            android:textStyle="bold" />
    </LinearLayout>

    <LinearLayout
        android:id="@+id/widget_today_list"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_marginTop="8dp"
        android:layout_weight="1"
        android:orientation="vertical" />

    <TextView
        android:id="@+id/widget_today_empty"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center"
        android:padding="12dp"
        android:text="Belum ada tugas hari ini ??"
        android:textColor="#94A3B8"
        android:textSize="12sp"
        android:visibility="gone" />
</LinearLayout>
```

Note: row rows will be inflated programmatically OR use 5 fixed row stubs. Prefer **5 fixed rows** in layout for RemoteViews simplicity — append after `widget_today_list` id change to fixed rows:

Replace list container with 5 row includes (same structure as old app). Full row layout `widget_today_row.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/row_root"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:gravity="center_vertical"
    android:orientation="horizontal"
    android:paddingVertical="4dp">

    <View
        android:id="@+id/row_checkbox"
        android:layout_width="14dp"
        android:layout_height="14dp"
        android:background="@drawable/widget_checkbox_todo" />

    <TextView
        android:id="@+id/row_title"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="8dp"
        android:layout_weight="1"
        android:ellipsize="end"
        android:maxLines="1"
        android:textColor="#FFFFFF"
        android:textSize="12sp" />

    <TextView
        android:id="@+id/row_time"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="6dp"
        android:textColor="#94A3B8"
        android:textSize="11sp" />
</LinearLayout>
```

Because RemoteViews cannot inflate arbitrary trees easily without `LayoutStub` complexity, **embed 5 copies of this row structure inline** in `widget_today.xml` under `@+id/widget_today_rows` with ids `row_1_checkbox`…`row_5_time`. Engineer: copy-paste 5 row blocks with numbered ids.

- [ ] **Step 6: widget_today_info.xml**

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:initialLayout="@layout/widget_today"
    android:minWidth="250dp"
    android:minHeight="110dp"
    android:targetCellWidth="4"
    android:targetCellHeight="2"
    android:updatePeriodMillis="0"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen" />
```

- [ ] **Step 7: TodayWidget.kt**

`android/app/src/main/kotlin/com/todoaw/todoaw/widget/TodayWidget.kt`:

```kotlin
package com.todoaw.todoaw.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import com.todoaw.todoaw.R

class TodayWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_today

    private val rowIds = listOf(1, 2, 3, 4, 5)

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_today_root)

        views.setTextViewText(R.id.widget_today_date, WidgetData.str(data, "dateLabel"))
        views.setTextColor(R.id.widget_today_date, p.muted)
        views.setTextViewText(R.id.widget_today_logo, "todoaw")
        views.setTextColor(R.id.widget_today_logo, p.text)

        val completed = WidgetData.int(data, "completedCount")
        val total = WidgetData.int(data, "totalCount")
        views.setTextViewText(R.id.widget_today_progress_text, "$completed/$total")
        views.setTextColor(R.id.widget_today_progress_text, p.text)

        val tasks = WidgetData.todayTasks(data)
        val empty = views.getViewVisibility(R.id.widget_today_empty)
        if (tasks.isEmpty()) {
            views.setViewVisibility(R.id.widget_today_empty, View.VISIBLE)
            views.setViewVisibility(R.id.widget_today_rows, View.GONE)
        } else {
            views.setViewVisibility(R.id.widget_today_empty, View.GONE)
            views.setViewVisibility(R.id.widget_today_rows, View.VISIBLE)
        }

        for (i in 1..5) {
            val titleId = context.resources.getIdentifier(
                "widget_today_row_${i}_title", "id", context.packageName)
            val timeId = context.resources.getIdentifier(
                "widget_today_row_${i}_time", "id", context.packageName)
            val cbId = context.resources.getIdentifier(
                "widget_today_row_${i}_checkbox", "id", context.packageName)
            val rowId = context.resources.getIdentifier(
                "widget_today_row_${i}", "id", context.packageName)

            val item = tasks.getOrNull(i - 1)
            if (item == null) {
                views.setViewVisibility(rowId, View.GONE)
                continue
            }
            views.setViewVisibility(rowId, View.VISIBLE)
            views.setTextViewText(titleId, item.title)
            views.setTextColor(titleId, p.text)
            views.setTextViewText(timeId, item.time)
            views.setTextColor(timeId, p.muted)
            views.setImageViewResource(
                cbId,
                if (item.done) R.drawable.widget_checkbox_done
                else R.drawable.widget_checkbox_todo
            )
            views.setOnClickPendingIntent(
                cbId,
                togglePending(context, 2000 + i, item.uuid),
            )
            views.setOnClickPendingIntent(
                rowId,
                activityPending(
                    context, 1000 + i,
                    com.todoaw.todoaw.widget.WidgetActionsNative.OPEN_TASK,
                    mapOf("uuid" to item.uuid),
                ),
            )
        }

        views.setOnClickPendingIntent(
            R.id.widget_today_logo,
            activityPending(context, 9000, com.todoaw.todoaw.widget.WidgetActionsNative.OPEN_HOME),
        )
    }

    override fun applySafeEmpty(context: Context, views: RemoteViews, data: SharedPreferences) {
        WidgetTheme.applyRoot(views, WidgetTheme.palette(data), R.id.widget_today_root)
    }
}
```

Create companion constants file `WidgetActionsNative.kt`:

```kotlin
package com.todoaw.todoaw.widget

object WidgetActionsNative {
    const val OPEN_HOME = "open_home"
    const val OPEN_NOTES = "open_notes"
    const val OPEN_DASHBOARD = "open_dashboard"
    const val OPEN_TASKS_PRIORITY = "open_tasks_priority"
    const val OPEN_TASK = "open_task"
    const val OPEN_NOTE = "open_note"
    const val TOGGLE_TASK = "toggle_task"
    const val ACTION_TOGGLE_TASK = "com.todoaw.todoaw.widget.ACTION_TOGGLE_TASK"
}
```

(Update BaseWidgetProvider.togglePending to use `WidgetActionsNative.ACTION_TOGGLE_TASK`.)

- [ ] **Step 8: WidgetActionReceiver.kt**

```kotlin
package com.todoaw.todoaw.widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class WidgetActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != WidgetActionsNative.ACTION_TOGGLE_TASK) return
        val uuid = intent.getStringExtra("uuid") ?: return
        try {
            val data = HomeWidgetPlugin.getData(context)
            data.edit()
                .putString("pending_action", WidgetActionsNative.TOGGLE_TASK)
                .putString("pending_uuid", uuid)
                .apply()
        } catch (_: Exception) {
        }
        // Ensure Flutter engine runs receiver callback
        try {
            es.antonborri.home_widget.HomeWidgetLaunchIntent.getActivity(
                context,
                com.todoaw.todoaw.MainActivity::class.java,
            )?.let { /* no-op launcher */ }
        } catch (_: Exception) {
        }
        // Kick Dart receiver via home_widget background broadcast mechanism:
        val launch = Intent(context, com.todoaw.todoaw.MainActivity::class.java).apply {
            action = WidgetActionsNative.TOGGLE_TASK
            putExtra("uuid", uuid)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(launch)
    }
}
```

**Correction for plan clarity:** Prefer home_widget’s documented pattern: broadcast ? `HomeWidgetReceiver` in Dart registered via `HomeWidgetWidget BroadcastReceiver`. Simplest reliable path for Batch 1:

1. Kotlin receiver writes `pending_action`/`pending_uuid` to HomeWidget prefs  
2. Starts MainActivity with action `toggle_task` + uuid  
3. `MainActivity.onNewIntent` / `onCreate` passes intent to Flutter  
4. Dart `home_screen` / main handler: if action toggle_task ? call repo toggle ? `updateAll` ? finish-not-needed (stay on home)  

Document in Task 9: handle `toggle_task` without forcing navigation when extras present from widget (use `PendingWidgetAction`).

- [ ] **Step 9: Manifest — register Today + receiver**

Edit `AndroidManifest.xml` before `</application>`:

```xml
        <receiver
            android:name=".widget.TodayWidget"
            android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>
            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/widget_today_info" />
        </receiver>

        <receiver
            android:name=".widget.WidgetActionReceiver"
            android:exported="false" />
```

- [ ] **Step 10: Build check**

Run: `flutter build apk --debug`  
Expected: BUILD SUCCESSFUL. Fix R imports / ids if merge fails.

- [ ] **Step 11: Commit**

```bash
git add android/app/src/main/kotlin/com/todoaw/todoaw/widget \
  android/app/src/main/res \
  android/app/src/main/AndroidManifest.xml
git commit -m "feat(widgets): Kotlin base + Today widget end-to-end"
```

**? Checkpoint:** install APK, add Today widget, verify list/progress/toggle/deep link on device.


---

## Task 5: Compact + Priority widgets

**Files:**
- Create: `android/.../widget/CompactWidget.kt`
- Create: `android/.../widget/PriorityWidget.kt`
- Create: `android/.../res/layout/widget_compact.xml`
- Create: `android/.../res/layout/widget_priority.xml`
- Create: `android/.../res/xml/widget_compact_info.xml`
- Create: `android/.../res/xml/widget_priority_info.xml`
- Modify: `AndroidManifest.xml`

- [ ] **Step 1: widget_compact.xml**

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/widget_compact_root"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#0F1729"
    android:gravity="center_vertical"
    android:orientation="horizontal"
    android:padding="12dp">

    <TextView
        android:id="@+id/widget_compact_progress"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:background="@drawable/widget_checkbox_done"
        android:gravity="center"
        android:minWidth="40dp"
        android:paddingHorizontal="8dp"
        android:paddingVertical="6dp"
        android:text="0/0"
        android:textColor="#FFFFFF"
        android:textSize="11sp"
        android:textStyle="bold" />

    <LinearLayout
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="10dp"
        android:layout_weight="1"
        android:orientation="vertical">

        <TextView
            android:id="@+id/widget_compact_next_title"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:ellipsize="end"
            android:maxLines="1"
            android:textColor="#FFFFFF"
            android:textSize="12sp" />

        <TextView
            android:id="@+id/widget_compact_next_time"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="#94A3B8"
            android:textSize="11sp" />
    </LinearLayout>

    <TextView
        android:id="@+id/widget_compact_chevron"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="&#8250;"
        android:textColor="#94A3B8"
        android:textSize="18sp" />
</LinearLayout>
```

- [ ] **Step 2: CompactWidget.kt**

```kotlin
package com.todoaw.todoaw.widget

import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.todoaw.todoaw.R

class CompactWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_compact

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_compact_root)

        val completed = WidgetData.int(data, "completedCount")
        val total = WidgetData.int(data, "totalCount")
        views.setTextViewText(R.id.widget_compact_progress, "$completed/$total")
        views.setTextColor(R.id.widget_compact_progress, p.text)

        val nextTitle = WidgetData.str(data, "nextTaskTitle")
        val nextTime = WidgetData.str(data, "nextTaskTime")
        val nextUuid = WidgetData.str(data, "nextTaskUuid")
        if (nextTitle.isBlank()) {
            views.setTextViewText(R.id.widget_compact_next_title, "Tidak ada tugas berikutnya")
            views.setTextColor(R.id.widget_compact_next_title, p.muted)
            views.setTextViewText(R.id.widget_compact_next_time, "")
        } else {
            views.setTextViewText(
                R.id.widget_compact_next_title,
                "Berikutnya: $nextTitle",
            )
            views.setTextColor(R.id.widget_compact_next_title, p.text)
            views.setTextViewText(R.id.widget_compact_next_time, nextTime)
            views.setTextColor(R.id.widget_compact_next_time, p.muted)
        }

        val click = if (nextUuid.isNotBlank()) {
            activityPending(
                context, 3100, WidgetActionsNative.OPEN_TASK,
                mapOf("uuid" to nextUuid),
            )
        } else {
            activityPending(context, 3101, WidgetActionsNative.OPEN_HOME)
        }
        views.setOnClickPendingIntent(R.id.widget_compact_root, click)
    }
}
```

- [ ] **Step 3: widget_compact_info.xml**

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:initialLayout="@layout/widget_compact"
    android:minWidth="250dp"
    android:minHeight="50dp"
    android:targetCellWidth="4"
    android:targetCellHeight="1"
    android:updatePeriodMillis="0"
    android:resizeMode="horizontal"
    android:widgetCategory="home_screen" />
```

- [ ] **Step 4: widget_priority.xml**

Structure: root `widget_priority_root`, header title + `widget_priority_count`, container `widget_priority_rows` with 5 rows, empty `widget_priority_empty`, footer `widget_priority_footer` text `Lihat semua ?`.

Each row N (1–5): `widget_priority_row_N`, `widget_priority_row_N_checkbox` (View), `widget_priority_row_N_title`, `widget_priority_row_N_badge` (TextView), `widget_priority_row_N_time`. Copy row block 5 times with numbered ids (same pattern as Today).

- [ ] **Step 5: PriorityWidget.kt**

```kotlin
package com.todoaw.todoaw.widget

import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import com.todoaw.todoaw.R

class PriorityWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_priority

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_priority_root)

        val tasks = WidgetData.priorityTasks(data)
        views.setTextViewText(R.id.widget_priority_count, "${tasks.size} tugas")
        views.setTextColor(R.id.widget_priority_count, p.muted)

        val empty = tasks.isEmpty()
        views.setViewVisibility(
            R.id.widget_priority_empty,
            if (empty) View.VISIBLE else View.GONE,
        )
        views.setViewVisibility(
            R.id.widget_priority_rows,
            if (empty) View.GONE else View.VISIBLE,
        )

        for (i in 1..5) {
            val rowId = resId(context, "widget_priority_row_$i")
            val cbId = resId(context, "widget_priority_row_${i}_checkbox")
            val titleId = resId(context, "widget_priority_row_${i}_title")
            val badgeId = resId(context, "widget_priority_row_${i}_badge")
            val timeId = resId(context, "widget_priority_row_${i}_time")

            val item = tasks.getOrNull(i - 1)
            if (item == null) {
                views.setViewVisibility(rowId, View.GONE)
                continue
            }
            views.setViewVisibility(rowId, View.VISIBLE)
            views.setTextViewText(titleId, item.title)
            views.setTextColor(titleId, p.text)
            views.setTextViewText(timeId, item.time)
            views.setTextColor(timeId, p.muted)
            val isHigh = item.level == "high"
            views.setTextViewText(badgeId, if (isHigh) "High" else "Medium")
            views.setInt(badgeId, "setBackgroundColor", if (isHigh) p.danger else p.warn)
            views.setTextColor(badgeId, 0xFFFFFFFF.toInt())
            views.setInt(
                cbId,
                "setBackgroundResource",
                if (item.done) R.drawable.widget_checkbox_done
                else R.drawable.widget_checkbox_todo,
            )
            views.setOnClickPendingIntent(cbId, togglePending(context, 4000 + i, item.uuid))
            views.setOnClickPendingIntent(
                rowId,
                activityPending(
                    context, 4500 + i, WidgetActionsNative.OPEN_TASK,
                    mapOf("uuid" to item.uuid),
                ),
            )
        }

        views.setOnClickPendingIntent(
            R.id.widget_priority_footer,
            activityPending(context, 4900, WidgetActionsNative.OPEN_TASKS_PRIORITY),
        )
    }

    private fun resId(context: Context, name: String): Int =
        context.resources.getIdentifier(name, "id", context.packageName)
}
```

- [ ] **Step 6: info XML + manifest** — compact 4×1, priority 4×2; same receiver pattern as Today.

- [ ] **Step 7: Build + commit**

Run: `flutter build apk --debug`  
Expected: SUCCESS.

```bash
git add android/app/src/main
git commit -m "feat(widgets): Compact and Priority widgets"
```

---

---

## Task 6: Dashboard widget

**Files:**
- Create: `widget/DashboardWidget.kt`
- Create: `res/layout/widget_dashboard.xml`
- Create: `res/xml/widget_dashboard_info.xml`
- Modify: `AndroidManifest.xml`

- [ ] **Step 1: Layout widget_dashboard.xml**

Sections (ids):
- `widget_dashboard_root` (LinearLayout vertical, bg `#0F1729`, padding 16dp)
- `widget_dashboard_greeting` (TextView, 16sp bold, color `#FFFFFF`)
- `widget_dashboard_sub` (TextView, 12sp, color `#94A3B8`, text static `Hari produktif ?`)
- Progress row: badge TextView `widget_dashboard_progress_text` (bg `@drawable/widget_checkbox_done`, white 11sp bold)
- Stat cards row (3× LinearLayout, bg `@drawable/widget_bg_rounded`, corner 12dp, padding 10dp, weight 1):
  - Card 1: `widget_dashboard_stat_tasks` (TextView number, 18sp bold) + static label `Tugas`
  - Card 2: `widget_dashboard_stat_notes` + static label `Catatan`
  - Card 3: `widget_dashboard_stat_total` + static label `Total`
- Next section: `widget_dashboard_next_title` (13sp, `#FFFFFF`), `widget_dashboard_next_time` (11sp, `#94A3B8`)
- Button row: `widget_dashboard_btn_add_task` (TextView `+ Tugas`, bg accent rounded), `widget_dashboard_btn_add_note` (TextView `+ Catatan`), `widget_dashboard_btn_view_all` (TextView `Semua`, outline style)

Static labels inside stat cards: plain TextView, not rebound.

- [ ] **Step 2: DashboardWidget.kt**

```kotlin
package com.todoaw.todoaw.widget

import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.todoaw.todoaw.R

class DashboardWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_dashboard

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_dashboard_root)

        views.setTextViewText(R.id.widget_dashboard_greeting, WidgetData.str(data, "greeting"))
        views.setTextColor(R.id.widget_dashboard_greeting, p.text)
        views.setTextColor(R.id.widget_dashboard_sub, p.muted)

        val completed = WidgetData.int(data, "completedCount")
        val total = WidgetData.int(data, "totalCount")
        views.setTextViewText(R.id.widget_dashboard_progress_text, "$completed/$total")
        views.setTextColor(R.id.widget_dashboard_progress_text, p.text)

        views.setTextViewText(R.id.widget_dashboard_stat_tasks, WidgetData.str(data, "tasksTodayCount"))
        views.setTextColor(R.id.widget_dashboard_stat_tasks, p.accent)
        views.setTextViewText(R.id.widget_dashboard_stat_notes, WidgetData.str(data, "notesTodayCount"))
        views.setTextColor(R.id.widget_dashboard_stat_notes, p.success)
        views.setTextViewText(R.id.widget_dashboard_stat_total, WidgetData.str(data, "totalTodayCount"))
        views.setTextColor(R.id.widget_dashboard_stat_total, p.accent)

        val nextTitle = WidgetData.str(data, "nextTaskTitle")
        val nextTime = WidgetData.str(data, "nextTaskTime")
        val nextUuid = WidgetData.str(data, "nextTaskUuid")
        views.setTextViewText(
            R.id.widget_dashboard_next_title,
            if (nextTitle.isBlank()) "Berikutnya: —" else "Berikutnya: $nextTitle",
        )
        views.setTextColor(R.id.widget_dashboard_next_title, p.text)
        views.setTextViewText(R.id.widget_dashboard_next_time, nextTime)
        views.setTextColor(R.id.widget_dashboard_next_time, p.muted)
        views.setOnClickPendingIntent(
            R.id.widget_dashboard_next_title,
            activityPending(
                context, 5100,
                if (nextUuid.isNotBlank()) WidgetActionsNative.OPEN_TASK else WidgetActionsNative.OPEN_HOME,
                if (nextUuid.isNotBlank()) mapOf("uuid" to nextUuid) else emptyMap(),
            ),
        )

        views.setOnClickPendingIntent(
            R.id.widget_dashboard_btn_add_task,
            activityPendingClass(
                context, 5200, QuickInputActivity::class.java,
                QuickInputActivity.ACTION_MODE,
                mapOf(QuickInputActivity.EXTRA_MODE to QuickInputActivity.MODE_TASK),
            ),
        )
        views.setOnClickPendingIntent(
            R.id.widget_dashboard_btn_add_note,
            activityPendingClass(
                context, 5201, QuickInputActivity::class.java,
                QuickInputActivity.ACTION_MODE,
                mapOf(QuickInputActivity.EXTRA_MODE to QuickInputActivity.MODE_NOTE),
            ),
        )
        views.setOnClickPendingIntent(
            R.id.widget_dashboard_btn_view_all,
            activityPending(context, 5300, WidgetActionsNative.OPEN_HOME),
        )
        views.setOnClickPendingIntent(
            R.id.widget_dashboard_progress_text,
            activityPending(context, 5301, WidgetActionsNative.OPEN_DASHBOARD),
        )
    }
}
```

Note: if `QuickInputActivity` not yet compiled (Task 7), leave the two add-button clicks as `activityPending(OPEN_HOME)` stubs and wire in Task 7 — or temporarily land Task 6 skeleton without add buttons; prefer full code above and land Task 6 after Task 7 if compile order requires (either works; README note in commit message if stubbed).

- [ ] **Step 3: info XML (4×4) + manifest**

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:initialLayout="@layout/widget_dashboard"
    android:minWidth="250dp"
    android:minHeight="250dp"
    android:targetCellWidth="4"
    android:targetCellHeight="4"
    android:updatePeriodMillis="0"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen" />
```

Manifest receiver `DashboardWidget` with same meta-data pattern as Today.

- [ ] **Step 4: Build + commit**

Run: `flutter build apk --debug`  
Expected: SUCCESS.

```bash
git add android/app/src/main
git commit -m "feat(widgets): Dashboard widget"
```

---

## Task 7: QuickInputActivity + Quick Add + Quick Note

**Files:**
- Create: `widget/QuickInputActivity.kt`
- Create: `widget/QuickAddWidget.kt`
- Create: `widget/QuickNoteWidget.kt`
- Create: `res/layout/widget_quick_add.xml`
- Create: `res/layout/widget_quick_note.xml`
- Create: `res/layout/activity_quick_input.xml`
- Create: `res/xml/widget_quick_add_info.xml`
- Create: `res/xml/widget_quick_note_info.xml`
- Modify: `res/values/styles.xml` (translucent theme)
- Create: `lib/services/widget_quick_input_channel.dart`
- Modify: `lib/main.dart`
- Modify: `android/.../MainActivity.kt` (engine cache)
- Modify: `AndroidManifest.xml`

- [ ] **Step 1: activity_quick_input.xml**

Vertical LinearLayout, transparent bg, centered card (`widget_bg_rounded`):
- `widget_quick_input_title` (TextView header)
- `widget_quick_input_field` (EditText, singleLine false, hint dynamic)
- `widget_quick_input_time` (EditText, hint `HH:mm (opsional)`, task only)
- `widget_quick_input_error` (TextView, red `#EF4444`, visibility gone)
- Row: `widget_quick_input_cancel` (Button/BORDER), `widget_quick_input_save` (Button accent)

- [ ] **Step 2: QuickInputActivity.kt**

```kotlin
package com.todoaw.todoaw.widget

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import com.todoaw.todoaw.R
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class QuickInputActivity : Activity() {
    companion object {
        const val ACTION_MODE = "com.todoaw.todoaw.widget.QUICK_INPUT"
        const val EXTRA_MODE = "mode"
        const val MODE_TASK = "task"
        const val MODE_NOTE = "note"
        const val CHANNEL = "todoaw/widget"
        const val CACHE_ID = "todoaw_engine"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
        window.setDimAmount(0.55f)
        setContentView(R.layout.activity_quick_input)

        val mode = intent.getStringExtra(EXTRA_MODE) ?: MODE_TASK
        val titleView = findViewById<TextView>(R.id.widget_quick_input_title)
        val field = findViewById<EditText>(R.id.widget_quick_input_field)
        val timeField = findViewById<EditText>(R.id.widget_quick_input_time)
        val error = findViewById<TextView>(R.id.widget_quick_input_error)
        val save = findViewById<Button>(R.id.widget_quick_input_save)
        val cancel = findViewById<Button>(R.id.widget_quick_input_cancel)

        if (mode == MODE_TASK) {
            titleView.text = "Tugas baru"
            field.hint = "Tambah tugas baru..."
            timeField.visibility = View.VISIBLE
            timeField.hint = "HH:mm (opsional)"
        } else {
            titleView.text = "Catatan cepat"
            field.hint = "Tulis catatan cepat..."
            timeField.visibility = View.GONE
        }

        cancel.setOnClickListener { finish() }
        save.setOnClickListener {
            val title = field.text.toString().trim()
            if (title.isEmpty()) {
                error.text = "Judul tidak boleh kosong"
                error.visibility = View.VISIBLE
                return@setOnClickListener
            }
            val time = timeField.text.toString().trim()
            saveViaFlutter(mode, title, time.ifBlank { null }) { ok, errMsg ->
                runOnUiThread {
                    if (ok) {
                        finish()
                    } else {
                        error.text = errMsg ?: "Gagal menyimpan, coba lagi"
                        error.visibility = View.VISIBLE
                    }
                }
            }
        }
    }

    private fun saveViaFlutter(
        mode: String,
        title: String,
        time: String?,
        callback: (Boolean, String?) -> Unit,
    ) {
        val engine = FlutterEngineCache.getInstance().get(CACHE_ID)
        if (engine == null) {
            val prefs = getSharedPreferences("HomeWidgetPreferences", MODE_PRIVATE)
            prefs.edit()
                .putString("pending_quick_mode", mode)
                .putString("pending_quick_title", title)
                .putString("pending_quick_time", time ?: "")
                .putString("pending_action", if (mode == MODE_TASK) "new_task" else "new_note")
                .apply()
            val launch = packageManager.getLaunchIntentForPackage(packageName)
            if (launch != null) {
                launch.putExtra("pending_quick_mode", mode)
                launch.putExtra("pending_quick_title", title)
                launch.putExtra("pending_quick_time", time ?: "")
                launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(launch)
            }
            callback(true, null)
            finish()
            return
        }
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        val args = mutableMapOf<String, Any?>(
            "mode" to mode,
            "title" to title,
        )
        if (time != null) args["time"] = time
        channel.invokeMethod("saveQuick", args) { result ->
            if (result != null && result.isSuccess) {
                val map = result.data as? Map<*, *>
                if (map["ok"] == true) callback(true, null)
                else callback(false, map["error"] as? String)
            } else {
                callback(false, result?.error?.message)
            }
        }
    }
}
```

- [ ] **Step 3: MainActivity engine cache**

In `MainActivity.configureFlutterEngine`, after `super`:

```kotlin
FlutterEngineCache.getInstance().put("todoaw_engine", flutterEngine)
```

Import `io.flutter.embedding.engine.FlutterEngineCache`.

- [ ] **Step 4: styles.xml translucent theme**

```xml
<style name="QuickInputTheme" parent="@android:style/Theme.Translucent.NoTitleBar">
    <item name="android:windowBackground">@android:color/transparent</item>
    <item name="android:colorBackground">@android:color/transparent</item>
</style>
```

Manifest:

```xml
        <activity
            android:name=".widget.QuickInputActivity"
            android:exported="true"
            android:theme="@style/QuickInputTheme"
            android:excludeFromRecents="true"
            android:launchMode="singleTop" />
```

- [ ] **Step 5: Quick Add / Quick Note layouts + providers**

`widget_quick_add.xml` / `widget_quick_note.xml`: horizontal, logo row optional, placeholder TextView (id `widget_quick_add_placeholder` / `widget_quick_note_placeholder`, muted text), circular accent `+` button (TextView id `widget_quick_add_plus` / `widget_quick_note_plus`, bg oval accent — add `@drawable/widget_btn_circle` oval shape accent).

`QuickAddWidget.kt` / `QuickNoteWidget.kt`:

```kotlin
package com.todoaw.todoaw.widget

import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.todoaw.todoaw.R

class QuickAddWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_quick_add

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_quick_add_root)
        views.setTextViewText(R.id.widget_quick_add_placeholder, "Tambah tugas baru...")
        views.setTextColor(R.id.widget_quick_add_placeholder, p.muted)
        val intent = android.content.Intent(context, QuickInputActivity::class.java)
            .setAction(QuickInputActivity.ACTION_MODE)
            .putExtra(QuickInputActivity.EXTRA_MODE, QuickInputActivity.MODE_TASK)
        val pi = android.app.PendingIntent.getActivity(
            context, 6100 + widgetId, intent,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.widget_quick_add_root, pi)
        views.setOnClickPendingIntent(R.id.widget_quick_add_plus, pi)
    }
}
```

Same for `QuickNoteWidget` with mode `note`, layout `widget_quick_note`, reqCode 6200, placeholder `Tulis catatan cepat...`.

`widget_quick_add_info.xml` / `widget_quick_note_info.xml`: 4×1, `updatePeriodMillis=0`. Manifest both receivers.

- [ ] **Step 6: Dart channel `lib/services/widget_quick_input_channel.dart`**

```dart
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../data/repositories/note_repository.dart';
import '../data/repositories/task_repository.dart';
import 'widget_bridge.dart';

const MethodChannel widgetQuickChannel = MethodChannel('todoaw/widget');

Future<void> setupWidgetQuickInputChannel({
  required ThemeMode Function() themeMode,
  required int Function() accentColor,
  required Brightness Function() platformBrightness,
}) async {
  widgetQuickChannel.setMethodCallHandler((call) async {
    if (call.method != 'saveQuick') {
      throw MissingPluginException();
    }
    final args = (call.arguments as Map).cast<String, dynamic>();
    final mode = args['mode'] as String;
    final title = (args['title'] as String).trim();
    final time = args['time'] as String?;
    if (title.isEmpty) {
      return {'ok': false, 'error': 'Judul tidak boleh kosong'};
    }
    try {
      if (mode == 'task') {
        DateTime? due;
        if (time != null && time.contains(':')) {
          final parts = time.split(':');
          final h = int.tryParse(parts[0]);
          final m = parts.length > 1 ? int.tryParse(parts[1]) : null;
          if (h != null && m != null) {
            final now = DateTime.now();
            due = DateTime(now.year, now.month, now.day, h, m);
          }
        }
        await TaskRepository().create(title: title, dueDate: due);
      } else {
        await NoteRepository().create(title: title, content: null);
      }
      await WidgetBridge.updateAll(
        themeMode: themeMode(),
        accentColor: accentColor(),
        platformBrightness: platformBrightness(),
      );
      return {'ok': true};
    } catch (e) {
      return {'ok': false, 'error': 'Gagal menyimpan: $e'};
    }
  });
}
```

Verify actual `TaskRepository.create` / `NoteRepository.create` signatures during implementation and adapt argument names (`content` vs `body`, etc.).

Also drain `pending_quick_*` keys from HomeWidget prefs on Dart startup if cold path was used: read via `HomeWidget.getWidgetData` or SharedPreferences `HomeWidgetPreferences` — implement drain helper in this file and call from `main()`.

Wire in `main()` before `runApp` (non-web only).

- [ ] **Step 7: Build + commit**

Run: `flutter build apk --debug`  
Expected: SUCCESS.

```bash
git add android/app/src/main lib
git commit -m "feat(widgets): QuickInput overlay + Quick Add/Quick Note widgets"
```

**? Checkpoint:** type task/note from home screen widget ? data appears in app.

---

## Task 8: Notes Today widget

**Files:**
- Create: `widget/NotesTodayWidget.kt`
- Create: `res/layout/widget_notes_today.xml`
- Create: `res/xml/widget_notes_today_info.xml`
- Modify: `AndroidManifest.xml`

- [ ] **Step 1: Layout widget_notes_today.xml**

Root `widget_notes_today_root` vertical:
- Header row: title `Notes Today` (static), date `widget_notes_today_date` (bound)
- Empty: `widget_notes_today_empty`
- 4 note cards: `widget_notes_today_row_N` (N=1..4) each with `widget_notes_today_row_N_title`, `widget_notes_today_row_N_preview`, `widget_notes_today_row_N_time`, optional `widget_notes_today_row_N_pin`

Copy card block 4 times with numbered ids (same pattern as Today rows).

- [ ] **Step 2: NotesTodayWidget.kt**

```kotlin
package com.todoaw.todoaw.widget

import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import com.todoaw.todoaw.R
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class NotesTodayWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_notes_today

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_notes_today_root)

        val dateFmt = SimpleDateFormat("EEEE, d MMM yyyy", Locale("id", "ID"))
        views.setTextViewText(R.id.widget_notes_today_date, dateFmt.format(Date()))
        views.setTextColor(R.id.widget_notes_today_date, p.muted)

        val notes = WidgetData.notesToday(data)
        val empty = notes.isEmpty()
        views.setViewVisibility(
            R.id.widget_notes_today_empty,
            if (empty) View.VISIBLE else View.GONE,
        )

        for (i in 1..4) {
            val rootId = resId(context, "widget_notes_today_row_$i")
            val titleId = resId(context, "widget_notes_today_row_${i}_title")
            val previewId = resId(context, "widget_notes_today_row_${i}_preview")
            val timeId = resId(context, "widget_notes_today_row_${i}_time")
            val pinId = resId(context, "widget_notes_today_row_${i}_pin")

            val item = notes.getOrNull(i - 1)
            if (item == null) {
                views.setViewVisibility(rootId, View.GONE)
                continue
            }
            views.setViewVisibility(rootId, View.VISIBLE)
            views.setTextViewText(titleId, item.title)
            views.setTextColor(titleId, p.text)
            views.setTextViewText(previewId, item.preview)
            views.setTextColor(previewId, p.muted)
            views.setTextViewText(timeId, item.time)
            views.setTextColor(timeId, p.muted)
            views.setViewVisibility(pinId, if (item.pinned) View.VISIBLE else View.GONE)
            views.setOnClickPendingIntent(
                rootId,
                activityPending(
                    context, 7100 + i, WidgetActionsNative.OPEN_NOTE,
                    mapOf("uuid" to item.uuid),
                ),
            )
        }

        views.setOnClickPendingIntent(
            R.id.widget_notes_today_date,
            activityPending(context, 7200, WidgetActionsNative.OPEN_NOTES),
        )
    }

    private fun resId(context: Context, name: String): Int =
        context.resources.getIdentifier(name, "id", context.packageName)
}
```

If `WidgetData.notesToday` not yet present, add during this task (JSON list key `notesTodayList`, same shape as task list: uuid/title/preview/time/pinned).

- [ ] **Step 3: info XML + manifest**

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:initialLayout="@layout/widget_notes_today"
    android:minWidth="250dp"
    android:minHeight="110dp"
    android:targetCellWidth="4"
    android:targetCellHeight="2"
    android:updatePeriodMillis="0"
    android:resizeMode="horizontal"
    android:widgetCategory="home_screen" />
```

- [ ] **Step 4: Build + commit**

Run: `flutter build apk --debug`  
Expected: SUCCESS.

```bash
git add android/app/src/main
git commit -m "feat(widgets): Notes Today widget"
```

---

---

## Task 9: Deep-link + toggle handling in Flutter UI

**Files:**
- Modify: `lib/presentation/screens/home_screen.dart`
- Modify: `lib/main.dart` (if needed for cold intent drain)
- Modify: `android/.../MainActivity.kt` (forward intent extras / HomeWidgetLaunchIntent)

- [ ] **Step 1: Restore widget action handling in HomeScreen**

Import `widget_actions.dart`, `task_form_screen.dart` / task form sheet, note form sheet.

In `_HomeScreenState.initState` post-frame, add `_handleWidgetAction()`:

```dart
  void _handleWidgetAction() {
    final action = PendingWidgetAction.action;
    if (action == null) return;
    final uuid = PendingWidgetAction.taskUuid;
    final noteUuid = PendingWidgetAction.noteUuid;
    PendingWidgetAction.clear();
    if (!mounted) return;
    switch (action) {
      case WidgetActions.openTask:
        if (uuid != null) showTaskFormSheet(context, taskId: uuid);
        break;
      case WidgetActions.openNote:
        if (noteUuid != null) showNoteFormSheet(context, noteId: noteUuid);
        break;
      case WidgetActions.openNotes:
        context.go('/notes');
        break;
      case WidgetActions.openDashboard:
        context.go('/dashboard');
        break;
      case WidgetActions.openTasksPriority:
        context.go('/');
        break;
      case WidgetActions.openHome:
        context.go('/');
        break;
      case WidgetActions.toggleTask:
        if (uuid != null) _toggleFromWidget(uuid);
        break;
      default:
        break;
    }
  }

  Future<void> _toggleFromWidget(String uuid) async {
    final tasks = ref.read(taskListProvider).value ?? [];
    final match = tasks.where((t) => t.uuid == uuid).firstOrNull;
    if (match != null) {
      await ref.read(taskListProvider.notifier).toggleComplete(match);
    }
  }
```

Wire home_widget initial + stream (only if `PendingWidgetAction` not already filled from Kotlin channel — pick ONE path; prefer home_widget props):

```dart
    if (!kIsWeb) {
      HomeWidget.initiallyLaunchedFromHomeWidget().then((data) {
        if (data != null) _applyWidgetProps(data);
      });
      HomeWidget.widgetClicked.listen((data) {
        if (data != null) _applyWidgetProps(data);
      });
    }
```

```dart
  void _applyWidgetProps(Map<String, Object?> data) {
    PendingWidgetAction.action = data['action'] as String?;
    PendingWidgetAction.taskUuid = data['uuid'] as String?;
    PendingWidgetAction.noteUuid = data['note_uuid'] as String?;
    _handleWidgetAction();
  }
```

**Path decision:** switch `BaseWidgetProvider.activityPending` to `HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, intent)` so extras reach `HomeWidget.widgetClicked`. For toggle actions, Kotlin still writes `pending_action`/`pending_uuid` to prefs first (existing WidgetActionReceiver flow), then launches app with HomeWidgetLaunchIntent carrying `action`/`uuid` extras as well. If both present, Dart prefers `PendingWidgetAction` filled from extras via `getInitialProps`/`widgetClicked`.

- [ ] **Step 2: MainActivity intent forwarding**

In `onCreate`/`onNewIntent`, if extras contain `action`, copy into MethodChannel `todoaw/widget_actions` OR leave for home_widget only. Batch 1: rely on HomeWidgetLaunchIntent + `HomeWidget.widgetClicked`; after toggle handled, optional `moveTaskToBack(true)` if launched solely for toggle — acceptable to open app briefly.

- [ ] **Step 3: Provider hooks after CRUD**

Edit `lib/providers/task_list_provider.dart`:
- After successful `toggleComplete`, create (when list changes), delete: `unawaited(refreshWidgetsFromPrefs());`

Edit `lib/providers/note_provider.dart`:
- After create/update/delete/togglePin: `unawaited(refreshWidgetsFromPrefs());`

Define once as top-level in `widget_bridge.dart` (or export from there):

```dart
Future<void> refreshWidgetsFromPrefs() async {
  // read theme_mode / accent_color from SharedPreferences,
  // platformBrightness from PlatformDispatcher,
  // then WidgetBridge.updateAll(...)
}
```

Avoid Ref cycles: do not take `Ref` for this helper — pure SharedPreferences + bridge.

- [ ] **Step 4: Analyze + unit tests**

Run: `flutter analyze`  
Expected: no errors.

Run: `flutter test test/services/widget_bridge_test.dart`  
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib android/app/src/main
git commit -m "feat(widgets): deep-link routing and refresh after CRUD"
```

---

## Task 10: WorkManager periodic refresh

**Files:**
- Create: `lib/services/widget_refresh_worker.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Worker callback**

```dart
// lib/services/widget_refresh_worker.dart
import 'package:workmanager/workmanager.dart';

import '../data/database.dart';
import 'widget_bridge.dart';

const String kWidgetRefreshTask = 'todoaw.widget.refresh';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task != kWidgetRefreshTask) return true;
    try {
      await AppDatabase.init();
      await refreshWidgetsFromPrefs();
      return true;
    } catch (_) {
      return false;
    }
  });
}
```

Verify actual `AppDatabase.init()` name / bootstrap during implementation — match `main()` database init path.

- [ ] **Step 2: Initialize in main() (non-web), guarded once**

```dart
    try {
      final prefs = await SharedPreferences.getInstance();
      final registered = prefs.getBool('widget_worker_registered') ?? false;
      if (!registered) {
        await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
        await Workmanager().registerPeriodicTask(
          '1',
          kWidgetRefreshTask,
          frequency: const Duration(minutes: 30),
          existingWorkPolicy: ExistingWorkPolicy.keep,
          constraints: Constraints(networkType: NetworkType.not_required),
        );
        await prefs.setBool('widget_worker_registered', true);
      }
    } catch (_) {
      // WorkManager optional; widgets still update via A/B paths
    }
```

Place after DB init, before `runApp`. Guard `!kIsWeb`.

- [ ] **Step 3: Smoke on device**

Open app once ? widgets refresh (path A/B). WorkManager runs ~30 min later — confirm no crash via logcat; optional adb shell dump of jobs:

```bash
adb shell dumpsys jobscheduler | findstr todoaw
```

- [ ] **Step 4: Commit**

```bash
git add lib
git commit -m "feat(widgets): WorkManager 30m periodic widget refresh"
```

---

## Task 11: Theme polish + hardening

**Files:**
- Modify: widget layouts/providers as needed (remove leftover hard-coded `#FFFFFF` in render paths — prefer `p.text`)
- Modify: `WidgetBridge` / `WidgetTheme` if light palette incomplete
- Modify: `test/services/widget_bridge_test.dart` if palette changes

- [ ] **Step 1: Verify light mode** — set theme Light in Settings ? add widget ? bg `#F8FAFC`, text `#0F172A`, muted `#64748B`, border `#E2E8F0`, accent follows app. Fix any hard-coded colors left in XML that override runtime palette (XML defaults only matter pre-bind; ensure `render()` always setTextColor/setBackground for bound views).

- [ ] **Step 2: Corrupt payload** — write garbage to prefs key `todayTaskList` (adb or debug) ? Today shows empty state, no crash.

- [ ] **Step 3: Overflow** — seed 100 tasks / 50 notes ? Today/Priority cap at 5, Notes Today at 4, no layout explosion, Dashboard stat numbers still fit card.

- [ ] **Step 4: Reboot device** — widgets keep last prefs (HomeWidgetPreferences survives).

- [ ] **Step 5: Logcat**

Run: `adb logcat | findstr /i "AndroidRuntime todoaw Widget"`  
Expected: no crash lines for `com.todoaw.todoaw`.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "fix(widgets): theme hardening and empty/corrupt payload safety"
```

---

## Task 12: Manual acceptance (user device)

**Files:** none (checklist)

- [ ] Run full checklist from spec §8 on personal device:

1. All 7 widgets appear in launcher at correct grid sizes (4×2, 4×4, 4×1, 4×2, 4×1, 4×2, 4×1)
2. Widget data matches app (today list, progress, next task, priority badges, notes)
3. Toggle from widget syncs back into app and other widgets
4. Quick Add / Quick Note save; empty title shows error; time parses to due
5. Deep links open correct screens (task form, note form, notes, dashboard, home, priority)
6. Theme (light/dark) + accent color follow app settings on all widgets
7. Empty states tidy (no tasks / no notes copy in Indonesian)
8. QuickInput from Dashboard buttons and Quick Add/Quick Note widgets works; WorkManager/refresh no crash
9. Reboot keeps widget data
10. No widget crash on device Android version (confirm = API 26 / target SDK)
11. 100+ tasks / 50+ notes: lists capped, no overflow

- [ ] **If all pass:** Batch 1 done — note in commit/changelog as desired; plan Batch 2 (Notes List, Mini, Note Preview, etc.) separately.

- [ ] **Final docs commit (if plan/spec still dirty):**

```bash
git status
git add -f docs/plans docs/specs
git commit -m "docs: widgets batch 1 plan complete"
```

---

## Self-review (plan vs spec)

| Spec item | Covered in |
|---|---|
| Approach A home_widget + RemoteViews | All tasks |
| 7 widgets Batch 1 | T4–T8 |
| Full interactivity toggle / quick input / deep link | T4, T7, T9 |
| Full theme light/dark + accent | T2–T3, T11 |
| Refresh A on data change / B on lifecycle / C WorkManager 30m | T3, T9, T10 |
| Payload contract keys | T2 `buildPayload` |
| Domain rules today / next / priority / notes | T2 tests |
| Empty + error states, Indonesian copy | T4–T8, T11 |
| Manual acceptance on personal device | T12 |
| iOS out of scope | not planned |
| Batch 2 out of scope | not planned |

**Type consistency:** `refreshWidgetsFromPrefs` defined once (T9 Step 3) as top-level in `widget_bridge.dart`; reused by Task/note providers (T9) and WorkManager worker (T10).

**Placeholders removed:** Priority/Dashboard/Notes layouts specify concrete ids and row-copy pattern (5/4 rows) matching Today stub pattern in T4.

**Compile-order note:** Task 6 Dashboard references `QuickInputActivity` (Task 7) — if landing Task 6 first, stub add-button clicks to `OPEN_HOME` and wire in Task 7; or land T7 before T6. Either order acceptable as long as final tree has full wiring.
