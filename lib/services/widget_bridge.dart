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

      // time-based sticker
      final hour = now.hour;
      final timeSticker = hour >= 5 && hour < 12
          ? 'sun'
          : hour >= 12 && hour < 18
              ? 'sparkle'
              : 'moon';

      // celebration mode (all tasks done)
      final celebration = total > 0 && completed == total ? 'confetti' : '';

      // fire mode (high streak)
      final streakMode = streak >= 5 ? 'fire' : '';

      // manual sticker from settings
      final manualSticker = prefs.getString('widget_sticker') ?? '';
      final customStickerText = prefs.getString('widget_sticker_text') ?? '';

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
      await HomeWidget.saveWidgetData('timeSticker', timeSticker);
      await HomeWidget.saveWidgetData('celebration', celebration);
      await HomeWidget.saveWidgetData('streakMode', streakMode);
      await HomeWidget.saveWidgetData('manualSticker', manualSticker);
      await HomeWidget.saveWidgetData('customStickerText', customStickerText);

      final titles = pending.take(5).map((t) => t.title).toList();
      await HomeWidget.saveWidgetData('taskList', jsonEncode(titles));

      final uuids = pending.take(5).map((t) => t.uuid).toList();
      await HomeWidget.saveWidgetData('taskUuids', jsonEncode(uuids));

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
