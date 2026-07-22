import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/data/repositories/task_repository.dart';

import '../test_helpers.dart';

void main() {
  late TaskRepository repo;

  setUpAll(() {
    setupTestDatabase();
  });

  setUp(() async {
    await initTestDb();
    repo = TaskRepository();
  });

  tearDown(() async {
    await closeTestDb();
  });

  group('TaskRepository.create', () {
    test('creates a task with required fields', () async {
      final task = await repo.create(title: 'Test Task');
      expect(task.uuid, isNotEmpty);
      expect(task.title, 'Test Task');
      expect(task.isCompleted, false);
      expect(task.createdAt, isNotNull);
    });

    test('creates a task with all fields', () async {
      final task = await repo.create(
        title: 'Full Task',
        description: 'Description',
        priority: Priority.p1,
        categoryId: 'cat-1',
        dueDate: DateTime(2026, 7, 25),
      );
      expect(task.description, 'Description');
      expect(task.priority, Priority.p1);
      expect(task.categoryId, 'cat-1');
      expect(task.dueDate, DateTime(2026, 7, 25));
    });
  });

  group('TaskRepository.getAll', () {
    test('returns empty list when no tasks', () async {
      final tasks = await repo.getAll();
      expect(tasks, isEmpty);
    });

    test('returns all tasks', () async {
      await repo.create(title: 'Task 1');
      await repo.create(title: 'Task 2');
      final tasks = await repo.getAll();
      expect(tasks.length, 2);
    });
  });

  group('TaskRepository.getActive', () {
    test('excludes archived tasks', () async {
      await repo.create(title: 'Active');
      final task2 = await repo.create(title: 'To Archive');
      await repo.update(task2.copyWith(isArchived: true));
      final active = await repo.getActive();
      expect(active.length, 1);
      expect(active.first.title, 'Active');
    });

    test('excludes deleted tasks', () async {
      await repo.create(title: 'Active');
      final task2 = await repo.create(title: 'To Delete');
      await repo.softDelete(task2.uuid);
      final active = await repo.getActive();
      expect(active.length, 1);
    });
  });

  group('TaskRepository.getById', () {
    test('returns task by uuid', () async {
      final created = await repo.create(title: 'Find Me');
      final found = await repo.getById(created.uuid);
      expect(found, isNotNull);
      expect(found!.title, 'Find Me');
    });

    test('returns null for non-existent uuid', () async {
      final found = await repo.getById('non-existent');
      expect(found, isNull);
    });
  });

  group('TaskRepository.update', () {
    test('updates task fields', () async {
      final created = await repo.create(title: 'Original');
      await repo.update(created.copyWith(title: 'Updated'));
      final updated = await repo.getById(created.uuid);
      expect(updated!.title, 'Updated');
    });

    test('bumps updatedAt', () async {
      final created = await repo.create(title: 'Test');
      final beforeUpdate = created.updatedAt;
      await Future.delayed(const Duration(milliseconds: 10));
      await repo.update(created.copyWith(title: 'Updated'));
      final updated = await repo.getById(created.uuid);
      expect(updated!.updatedAt.isAfter(beforeUpdate), true);
    });
  });

  group('TaskRepository.softDelete / restore', () {
    test('softDelete sets deletedAt', () async {
      final task = await repo.create(title: 'To Delete');
      await repo.softDelete(task.uuid);
      final deleted = await repo.getById(task.uuid);
      expect(deleted!.deletedAt, isNotNull);
    });

    test('restore clears deletedAt', () async {
      final task = await repo.create(title: 'To Restore');
      await repo.softDelete(task.uuid);
      await repo.restore(task.uuid);
      final restored = await repo.getById(task.uuid);
      expect(restored!.deletedAt, isNull);
    });
  });

  group('TaskRepository.getTrashed', () {
    test('returns only deleted tasks', () async {
      await repo.create(title: 'Active');
      final task2 = await repo.create(title: 'Deleted');
      await repo.softDelete(task2.uuid);
      final trashed = await repo.getTrashed();
      expect(trashed.length, 1);
      expect(trashed.first.title, 'Deleted');
    });

    test('sorts by most recently deleted first', () async {
      final t1 = await repo.create(title: 'First');
      final t2 = await repo.create(title: 'Second');
      await repo.softDelete(t1.uuid);
      await Future.delayed(const Duration(milliseconds: 10));
      await repo.softDelete(t2.uuid);
      final trashed = await repo.getTrashed();
      expect(trashed.first.title, 'Second');
    });
  });

  group('TaskRepository.delete', () {
    test('permanently deletes a task', () async {
      final task = await repo.create(title: 'To Delete');
      await repo.delete(task.uuid);
      final found = await repo.getById(task.uuid);
      expect(found, isNull);
    });
  });

  group('TaskRepository.search', () {
    test('finds tasks by title', () async {
      await repo.create(title: 'Buy milk');
      await repo.create(title: 'Walk dog');
      final results = await repo.search('milk');
      expect(results.length, 1);
      expect(results.first.title, 'Buy milk');
    });

    test('finds tasks by description', () async {
      await repo.create(
        title: 'Grocery',
        description: 'Get eggs and bread',
      );
      final results = await repo.search('eggs');
      expect(results.length, 1);
    });

    test('returns empty for unmatched query', () async {
      await repo.create(title: 'Task');
      final results = await repo.search('zzzzz');
      expect(results, isEmpty);
    });
  });

  group('TaskRepository.emptyTrash', () {
    test('permanently deletes all trashed tasks', () async {
      await repo.create(title: 'Active');
      final t2 = await repo.create(title: 'Trashed');
      await repo.softDelete(t2.uuid);
      await repo.emptyTrash();
      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.title, 'Active');
    });
  });
}
