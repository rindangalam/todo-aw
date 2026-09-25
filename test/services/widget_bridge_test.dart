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

    test('progress: completed/total, zero total → 0', () {
      final empty = WidgetBridge.progressFor([], startOfToday);
      expect(empty, 0);
      final tasks = [
        task(
          uuid: 'a',
          title: 'x',
          isCompleted: true,
          dueDate: startOfToday.add(const Duration(hours: 1)),
        ),
        task(
          uuid: 'b',
          title: 'y',
          dueDate: startOfToday.add(const Duration(hours: 2)),
        ),
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
        task(
          uuid: 'done',
          title: 'Done',
          priority: Priority.p1,
          isCompleted: true,
        ),
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
        note(
          uuid: 'n1',
          title: 'Old pin',
          isPinned: true,
          createdAt: startOfToday.add(const Duration(hours: 8)),
          updatedAt: startOfToday.add(const Duration(hours: 8)),
        ),
        note(
          uuid: 'n2',
          title: 'Created now',
          createdAt: startOfToday.add(const Duration(hours: 10)),
        ),
        note(
          uuid: 'n3',
          title: 'Archived',
          isArchived: true,
          createdAt: startOfToday,
        ),
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
