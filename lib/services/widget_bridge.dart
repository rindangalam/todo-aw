import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/task_repository.dart';

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
      final accentValue = prefs.getInt('accent_color') ?? 0xFF0EA5E9;

      final r = ((accentValue >> 16) & 0xFF) * 75 ~/ 100;
      final g = ((accentValue >> 8) & 0xFF) * 75 ~/ 100;
      final b = (accentValue & 0xFF) * 75 ~/ 100;
      final widgetBg = (0xFF << 24) | (r << 16) | (g << 8) | b;
      const textColor = 0xFFFFFFFF;

      final pending = tasks.where((t) => !t.isCompleted).toList();
      final total = tasks.length;
      final completed = total - pending.length;
      final progress = total > 0 ? (completed * 100 ~/ total) : 0;

      await HomeWidget.saveWidgetData(
          'pendingCount', pending.length.toString());
      await HomeWidget.saveWidgetData('completedCount', completed.toString());
      await HomeWidget.saveWidgetData('totalCount', total.toString());
      await HomeWidget.saveWidgetData('progress', progress.toString());
      await HomeWidget.saveWidgetData('streak', streak.toString());
      await HomeWidget.saveWidgetData(
          'widgetBg', widgetBg.toRadixString(16).padLeft(8, '0'));
      await HomeWidget.saveWidgetData(
          'accentColor', accentValue.toRadixString(16).padLeft(8, '0'));
      await HomeWidget.saveWidgetData(
          'textColor', textColor.toRadixString(16).padLeft(8, '0'));

      final titles = pending.take(5).map((t) => t.title).toList();
      await HomeWidget.saveWidgetData('taskList', jsonEncode(titles));

      const pkg = 'com.todoaw.todoaw';
      await HomeWidget.updateWidget(
        qualifiedAndroidName: '$pkg.TodoawCompactWidget',
      );
      await HomeWidget.updateWidget(
        qualifiedAndroidName: '$pkg.TodoawMediumWidget',
      );
      await HomeWidget.updateWidget(
        qualifiedAndroidName: '$pkg.TodoawListWidget',
      );
    } catch (_) {}
  }
}
