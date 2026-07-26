import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';
import '../domain/services/notification_service.dart';
import '../domain/services/recurring_task_service.dart';
import '../services/widget_bridge.dart';
import 'stats_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskListNotifier(ref.read(taskRepositoryProvider), ref);
});

final archivedTaskListProvider = FutureProvider<List<Task>>((ref) {
  return ref.read(taskRepositoryProvider).getArchived();
});

final templateListProvider = FutureProvider<List<Task>>((ref) {
  return ref.read(taskRepositoryProvider).getTemplates();
});

class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;
  final Ref _ref;
  final _recurringService = RecurringTaskService();

  TaskListNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getActive());
    WidgetBridge.updateWidget();
  }

  Future<void> refresh() async {
    final result = await AsyncValue.guard(() => _repository.getActive());
    if (result is AsyncData) {
      state = result;
    }
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    state = AsyncValue.data(
      (state.value ?? [])
          .map((t) => t.uuid == task.uuid ? updated : t)
          .toList(),
    );
    await _repository.update(updated);

    _ref.invalidate(statsProvider);

    // If recurring task was completed, generate next occurrence
    if (updated.isCompleted && task.isRecurring) {
      final nextTask = _recurringService.generateNext(task);
      if (nextTask != null) {
        final created = await _repository.createFromTask(nextTask);
        if (created.dueDate != null) {
          _scheduleNotification(created);
        }
        // Need to refresh to show the new recurring occurrence
        await refresh();
        return;
      }
    }

    WidgetBridge.updateWidget();
  }

  Future<Task> createTask({
    required String title,
    String? description,
    Priority priority = Priority.p3,
    String? categoryId,
    DateTime? dueDate,
    bool isRecurring = false,
    String? recurringRule,
    int? reminderMinutes,
    int? estimatedMinutes,
  }) async {
    final task = await _repository.create(
      title: title,
      description: description,
      priority: priority,
      categoryId: categoryId,
      dueDate: dueDate,
      isRecurring: isRecurring,
      recurringRule: recurringRule,
    );
    if (task.dueDate != null) {
      _scheduleNotification(task.copyWith(reminderMinutes: reminderMinutes));
    }
    _ref.invalidate(statsProvider);
    await load();
    return task;
  }

  Future<void> updateTask(Task task) async {
    state = AsyncValue.data(
      (state.value ?? []).map((t) => t.uuid == task.uuid ? task : t).toList(),
    );
    await NotificationService.cancelNotification(task.uuid);
    if (task.dueDate != null) {
      _scheduleNotification(task);
    }
    await _repository.update(task);
    _ref.invalidate(statsProvider);
    WidgetBridge.updateWidget();
  }

  Future<void> archive(Task task) async {
    state = AsyncValue.data(
      (state.value ?? []).where((t) => t.uuid != task.uuid).toList(),
    );
    await _repository.update(task.copyWith(isArchived: true));
    WidgetBridge.updateWidget();
  }

  Future<void> unarchive(Task task) async {
    state = AsyncValue.data(
      [task.copyWith(isArchived: false), ...(state.value ?? [])],
    );
    await _repository.update(task.copyWith(isArchived: false));
    WidgetBridge.updateWidget();
  }

  Future<void> softDelete(Task task) async {
    state = AsyncValue.data(
      (state.value ?? []).where((t) => t.uuid != task.uuid).toList(),
    );
    await NotificationService.cancelNotification(task.uuid);
    await _repository.softDelete(task.uuid);
    _ref.invalidate(statsProvider);
    WidgetBridge.updateWidget();
  }

  Future<void> batchComplete(Set<String> ids) async {
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.map((t) {
        if (ids.contains(t.uuid)) return t.copyWith(isCompleted: true);
        return t;
      }).toList(),
    );
    final all = await _repository.getAll();
    for (final task in all) {
      if (ids.contains(task.uuid) && !task.isCompleted) {
        await _repository.update(task.copyWith(isCompleted: true));
      }
    }
    _ref.invalidate(statsProvider);
    WidgetBridge.updateWidget();
  }

  Future<void> batchArchive(Set<String> ids) async {
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.where((t) => !ids.contains(t.uuid)).toList(),
    );
    for (final task in current) {
      if (ids.contains(task.uuid)) {
        await _repository.update(task.copyWith(isArchived: true));
      }
    }
    WidgetBridge.updateWidget();
  }

  Future<void> batchDelete(Set<String> ids) async {
    state = AsyncValue.data(
      (state.value ?? []).where((t) => !ids.contains(t.uuid)).toList(),
    );
    for (final id in ids) {
      await _repository.softDelete(id);
    }
    _ref.invalidate(statsProvider);
    WidgetBridge.updateWidget();
  }

  Future<Task> saveAsTemplate(Task task) async {
    final template = await _repository.createTemplateFromTask(task);
    await load();
    return template;
  }

  Future<Task> createFromTemplate(String templateId) async {
    final template = await _repository.getById(templateId);
    if (template == null) throw Exception('Template not found');
    final task = await _repository.createFromTask(template);
    if (task.dueDate != null) {
      _scheduleNotification(task);
    }
    _ref.invalidate(statsProvider);
    await load();
    return task;
  }

  void _scheduleNotification(Task task) {
    final minutes = task.reminderMinutes ?? 30;
    final remindAt = task.dueDate!.subtract(Duration(minutes: minutes));
    if (remindAt.isBefore(DateTime.now())) return;
    NotificationService.scheduleNotification(
      id: task.uuid,
      title: 'Task Reminder',
      body: task.title,
      scheduledDate: remindAt,
    );
  }
}
