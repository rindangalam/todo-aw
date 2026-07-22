import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/models/task.dart';

void main() {
  final now = DateTime(2026, 7, 20, 10, 0, 0);
  final baseTask = Task(
    uuid: 'test-1',
    title: 'Buy groceries',
    description: 'Milk, eggs, bread',
    isCompleted: false,
    priority: Priority.p1,
    categoryId: 'cat-1',
    dueDate: DateTime(2026, 7, 21),
    createdAt: now,
    updatedAt: now,
  );

  group('Task constructor', () {
    test('creates task with required fields', () {
      final task = Task(
        uuid: 'test-1',
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );
      expect(task.uuid, 'test-1');
      expect(task.title, 'Test');
      expect(task.isCompleted, false);
      expect(task.priority, Priority.p3);
    });
  });

  group('Task.copyWith', () {
    test('returns same instance when no args', () {
      final copy = baseTask.copyWith();
      expect(copy.uuid, baseTask.uuid);
      expect(copy.title, baseTask.title);
    });

    test('overrides specified fields', () {
      final copy = baseTask.copyWith(title: 'New Title', isCompleted: true);
      expect(copy.title, 'New Title');
      expect(copy.isCompleted, true);
      expect(copy.priority, baseTask.priority);
    });

    test('does not override nullable field when null is passed', () {
      final copy = baseTask.copyWith(description: null);
      expect(copy.description, baseTask.description);
    });
  });

  group('Task.toMap / fromMap', () {
    test('round-trip preserves all fields', () {
      final map = baseTask.toMap();
      final restored = Task.fromMap(map);
      expect(restored.uuid, baseTask.uuid);
      expect(restored.title, baseTask.title);
      expect(restored.description, baseTask.description);
      expect(restored.isCompleted, baseTask.isCompleted);
      expect(restored.priority, baseTask.priority);
      expect(restored.categoryId, baseTask.categoryId);
      expect(restored.dueDate, baseTask.dueDate);
      expect(restored.isRecurring, baseTask.isRecurring);
      expect(restored.createdAt, baseTask.createdAt);
      expect(restored.updatedAt, baseTask.updatedAt);
    });

    test('round-trip with nullable fields as null', () {
      final task = Task(
        uuid: 'test-2',
        title: 'Minimal',
        createdAt: now,
        updatedAt: now,
      );
      final map = task.toMap();
      final restored = Task.fromMap(map);
      expect(restored.description, null);
      expect(restored.categoryId, null);
      expect(restored.dueDate, null);
      expect(restored.recurringRule, null);
      expect(restored.parentId, null);
      expect(restored.deletedAt, null);
    });

    test('maps boolean fields as 0/1 integers', () {
      final completed = baseTask.copyWith(isCompleted: true);
      final map = completed.toMap();
      expect(map['isCompleted'], 1);

      final notCompleted = baseTask.copyWith(isCompleted: false);
      final map2 = notCompleted.toMap();
      expect(map2['isCompleted'], 0);
    });

    test('maps priority as integer index', () {
      final map = baseTask.toMap();
      expect(map['priority'], 0); // Priority.p1 index is 0
    });

    test('handles deletedAt serialization', () {
      final deleted = baseTask.copyWith(
        deletedAt: DateTime(2026, 7, 19),
      );
      final map = deleted.toMap();
      expect(map['deletedAt'], '2026-07-19T00:00:00.000');

      final restored = Task.fromMap(map);
      expect(restored.deletedAt, DateTime(2026, 7, 19));
    });
  });
}
