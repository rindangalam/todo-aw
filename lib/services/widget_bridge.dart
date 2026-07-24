import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../data/repositories/task_repository.dart';

class WidgetBridge {
  static const String widgetName = 'TodoawWidget';
  static const String groupId = 'todoaw_widget_group';

  static Future<void> updateWidget() async {
    try {
      final repo = TaskRepository();
      final tasks = await repo.getActive();

      final pending = tasks.where((t) => !t.isCompleted).toList();
      final total = tasks.length;
      final completed = total - pending.length;

      await HomeWidget.saveWidgetData(
          'pendingCount', pending.length.toString());
      await HomeWidget.saveWidgetData('completedCount', completed.toString());
      await HomeWidget.saveWidgetData('totalCount', total.toString());

      final titles = pending.take(5).map((t) => t.title).toList();
      await HomeWidget.saveWidgetData('taskList', jsonEncode(titles));

      const pkg = 'com.todoaw.todoaw';
      await HomeWidget.updateWidget(
        qualifiedAndroidName: '$pkg.TodoawCompactWidget',
      );
      await HomeWidget.updateWidget(
        qualifiedAndroidName: '$pkg.TodoawListWidget',
      );
    } catch (_) {}
  }
}
