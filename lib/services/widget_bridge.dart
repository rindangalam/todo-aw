import 'dart:convert';

import 'package:intl/intl.dart';

import '../data/models/note.dart';
import '../data/models/task.dart';
import '../data/repositories/note_repository.dart';
import '../data/repositories/task_repository.dart';

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

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isSameDay(DateTime a, DateTime b) => startOfDay(a) == startOfDay(b);

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
    return (done * 100 / scope.length).round();
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
        .where((t) => !t.isCompleted && !t.isArchived && t.deletedAt == null)
        .toList();
    final now = DateTime.now();
    final future = pending
        .where((t) => t.dueDate != null && t.dueDate!.isAfter(now))
        .toList()
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
    String hex(int argb) => argb.toRadixString(16).toUpperCase().padLeft(8, '0');
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

  /// Build all SharedPreferences key/values (pure — for tests + updateAll).
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
      'tasksTodayCount': '${todayPending.length}',
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
