import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../database.dart';
import '../models/task.dart';

class TaskRepository {
  final _uuid = const Uuid();

  Future<List<Task>> getAll() => AppDatabase.getAllTasks();

  Future<List<Task>> getActive() => AppDatabase.getActiveTasks();

  Future<List<Task>> getTrashed() async {
    final all = await AppDatabase.getAllTasks();
    final trashed = all.where((t) => t.deletedAt != null).toList();
    trashed.sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));
    return trashed;
  }

  Future<Task?> getById(String uuid) => AppDatabase.getTask(uuid);

  Future<Task> create({
    required String title,
    String? description,
    Priority priority = Priority.p3,
    String? categoryId,
    DateTime? dueDate,
    bool isRecurring = false,
    String? recurringRule,
    String? parentId,
  }) async {
    final now = DateTime.now();
    final task = Task(
      uuid: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      categoryId: categoryId,
      dueDate: dueDate,
      isRecurring: isRecurring,
      recurringRule: recurringRule,
      parentId: parentId,
      createdAt: now,
      updatedAt: now,
    );
    await AppDatabase.insertTask(task);
    return task;
  }

  Future<void> update(Task task) async {
    await AppDatabase.updateTask(task.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> delete(String uuid) async {
    await AppDatabase.deleteTask(uuid);
  }

  Future<void> softDelete(String uuid) async {
    final task = await getById(uuid);
    if (task != null) {
      await AppDatabase.updateTask(task.copyWith(deletedAt: DateTime.now()));
    }
  }

  Future<void> restore(String uuid) async {
    final task = await getById(uuid);
    if (task != null) {
      await AppDatabase.updateTask(Task(
        uuid: task.uuid,
        title: task.title,
        description: task.description,
        isCompleted: task.isCompleted,
        priority: task.priority,
        categoryId: task.categoryId,
        dueDate: task.dueDate,
        isRecurring: task.isRecurring,
        recurringRule: task.recurringRule,
        parentId: task.parentId,
        isArchived: task.isArchived,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<List<Task>> search(String query) => AppDatabase.searchTasks(query);

  Future<void> emptyTrash() async {
    final trashed = await getTrashed();
    for (final task in trashed) {
      await AppDatabase.deleteTask(task.uuid);
    }
  }

  Future<void> purgeOldTrash() async {
    final all = await AppDatabase.getAllTasks();
    final cutoff = DateTime.now()
        .subtract(const Duration(days: AppConstants.trashAutoPurgeDays));
    for (final task in all) {
      if (task.deletedAt != null && task.deletedAt!.isBefore(cutoff)) {
        await AppDatabase.deleteTask(task.uuid);
      }
    }
  }
}
