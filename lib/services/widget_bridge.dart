import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/task_repository.dart';
import '../data/repositories/note_repository.dart';

class WidgetBridge {
  static const String widgetName = 'TodoawWidget';
  static const String groupId = 'todoaw_widget_group';

  static Future<void> updateWidget() async {
    try {
      final repo = TaskRepository();
      final tasks = await repo.getActive();
      final allTasks = await repo.getAll();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int streak = 0;
      var checkDate = today.subtract(const Duration(days: 1));
      final completedPerDay = <int, int>{};
      for (final task in allTasks) {
        if (task.isCompleted) {
          final day = DateTime(
              task.updatedAt.year, task.updatedAt.month, task.updatedAt.day);
          completedPerDay[day.millisecondsSinceEpoch] =
              (completedPerDay[day.millisecondsSinceEpoch] ?? 0) + 1;
        }
      }
      while (completedPerDay.containsKey(checkDate.millisecondsSinceEpoch)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      final prefs = await SharedPreferences.getInstance();

      // Dark Blue Premium theme colors
      const widgetBg = 0xFF0F1729;
      const cardBg = 0xFF1A2540;
      const accentColor = 0xFF3B82F6;
      const textColor = 0xFFFFFFFF;
      const mutedColor = 0xFF94A3B8;

      final pending = tasks.where((t) => !t.isCompleted).toList();
      final total = tasks.length;
      final completed = total - pending.length;
      final progress = total > 0 ? (completed * 100 ~/ total) : 0;

      // Next task (first pending with dueDate, sorted by dueDate)
      final withDue = pending.where((t) => t.dueDate != null).toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
      final nextTask = withDue.isNotEmpty ? withDue.first : null;
      final nextTaskTitle = nextTask?.title ?? '';
      final nextTaskTime = nextTask?.dueDate != null
          ? '${nextTask!.dueDate!.hour.toString().padLeft(2, '0')}:${nextTask.dueDate!.minute.toString().padLeft(2, '0')}'
          : '';

      // Task list data
      final titles = pending.take(5).map((t) => t.title).toList();
      final uuids = pending.take(5).map((t) => t.uuid).toList();
      final taskTimes = pending.take(5).map((t) {
        if (t.dueDate == null) return '';
        return '${t.dueDate!.hour.toString().padLeft(2, '0')}:${t.dueDate!.minute.toString().padLeft(2, '0')}';
      }).toList();

      await HomeWidget.saveWidgetData(
          'pendingCount', pending.length.toString());
      await HomeWidget.saveWidgetData('completedCount', completed.toString());
      await HomeWidget.saveWidgetData('totalCount', total.toString());
      await HomeWidget.saveWidgetData('progress', progress.toString());
      await HomeWidget.saveWidgetData('streak', streak.toString());
      await HomeWidget.saveWidgetData(
          'widgetBg', widgetBg.toRadixString(16).padLeft(8, '0'));
      await HomeWidget.saveWidgetData(
          'accentColor', accentColor.toRadixString(16).padLeft(8, '0'));
      await HomeWidget.saveWidgetData(
          'textColor', textColor.toRadixString(16).padLeft(8, '0'));
      await HomeWidget.saveWidgetData(
          'mutedColor', mutedColor.toRadixString(16).padLeft(8, '0'));
      await HomeWidget.saveWidgetData(
          'cardBg', cardBg.toRadixString(16).padLeft(8, '0'));
      await HomeWidget.saveWidgetData('nextTaskTitle', nextTaskTitle);
      await HomeWidget.saveWidgetData('nextTaskTime', nextTaskTime);
      await HomeWidget.saveWidgetData('taskList', jsonEncode(titles));
      await HomeWidget.saveWidgetData('taskUuids', jsonEncode(uuids));
      await HomeWidget.saveWidgetData('taskTimes', jsonEncode(taskTimes));

      // Notes data
      final noteRepo = NoteRepository();
      final allNotes = await noteRepo.getAll();
      final activeNotes = allNotes.where((n) => !n.isArchived).toList();
      final todayNotes = activeNotes.where((n) {
        final created = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
        return created.isAtSameMomentAs(today);
      }).toList();

      final noteObjects = todayNotes.take(4).map((n) {
        return {
          'title': n.title,
          'content': n.content ?? '',
          'createdAt': n.createdAt.toIso8601String(),
        };
      }).toList();
      final noteUuids = todayNotes.take(4).map((n) => n.uuid).toList();

      await HomeWidget.saveWidgetData('notesList', jsonEncode(noteObjects));
      await HomeWidget.saveWidgetData('notesUuids', jsonEncode(noteUuids));

      const pkg = 'com.todoaw.todoaw';
      await HomeWidget.updateWidget(
        qualifiedAndroidName: '$pkg.TodayWidget',
      );
      await HomeWidget.updateWidget(
        qualifiedAndroidName: '$pkg.CompactWidget',
      );
      await HomeWidget.updateWidget(
        qualifiedAndroidName: '$pkg.QuickAddWidget',
      );
      await HomeWidget.updateWidget(
        qualifiedAndroidName: '$pkg.NotesTodayWidget',
      );
      await HomeWidget.updateWidget(
        qualifiedAndroidName: '$pkg.QuickNoteWidget',
      );
    } catch (_) {}
  }
}
