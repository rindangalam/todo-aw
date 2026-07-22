import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';
import '../domain/services/notification_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskListNotifier(ref.read(taskRepositoryProvider));
});

class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;

  TaskListNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getActive());
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
    await load();
  }

  Future<void> createTask({
    required String title,
    String? description,
    Priority priority = Priority.p3,
    String? categoryId,
    DateTime? dueDate,
    bool isRecurring = false,
    String? recurringRule,
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
      _scheduleNotification(task);
    }
    await load();
  }

  Future<void> updateTask(Task task) async {
    await NotificationService.cancelNotification(task.uuid);
    if (task.dueDate != null) {
      _scheduleNotification(task);
    }
    await _repository.update(task);
    await load();
  }

  Future<void> archive(Task task) async {
    await _repository.update(task.copyWith(isArchived: true));
    await load();
  }

  Future<void> unarchive(Task task) async {
    await _repository.update(task.copyWith(isArchived: false));
    await load();
  }

  Future<void> softDelete(Task task) async {
    await NotificationService.cancelNotification(task.uuid);
    await _repository.softDelete(task.uuid);
    await load();
  }

  void _scheduleNotification(Task task) {
    final remindAt = task.dueDate!.subtract(const Duration(minutes: 30));
    NotificationService.scheduleNotification(
      id: task.uuid,
      title: 'Task Reminder',
      body: task.title,
      scheduledDate: remindAt,
    );
  }
}
