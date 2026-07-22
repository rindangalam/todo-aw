import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/models/filter_state.dart';
import 'package:todoaw/data/models/task.dart';

void main() {
  final now = DateTime(2026, 7, 20);
  final task1 = Task(
    uuid: '1',
    title: 'Task 1',
    isCompleted: false,
    priority: Priority.p1,
    categoryId: 'cat-1',
    createdAt: now,
    updatedAt: now,
  );
  final task2 = Task(
    uuid: '2',
    title: 'Task 2',
    isCompleted: true,
    priority: Priority.p2,
    categoryId: 'cat-2',
    createdAt: now,
    updatedAt: now,
  );
  final task3 = Task(
    uuid: '3',
    title: 'Task 3',
    isCompleted: false,
    priority: Priority.p3,
    categoryId: null,
    isArchived: true,
    createdAt: now,
    updatedAt: now,
  );

  group('FilterState', () {
    test('default has no filters', () {
      const state = FilterState();
      expect(state.showCompleted, true);
      expect(state.priority, null);
      expect(state.categoryId, null);
      expect(state.showArchived, false);
      expect(state.isActive, false);
    });

    test('isActive returns true when any filter is set', () {
      expect(
        const FilterState(showCompleted: false).isActive,
        true,
      );
      expect(
        const FilterState(priority: Priority.p1).isActive,
        true,
      );
      expect(
        const FilterState(categoryId: 'cat-1').isActive,
        true,
      );
      expect(
        const FilterState(showArchived: true).isActive,
        true,
      );
    });
  });

  group('FilterState.copyWith', () {
    test('returns same when no args', () {
      const state = FilterState(showCompleted: false);
      expect(state.copyWith().showCompleted, false);
    });

    test('overrides specified fields', () {
      const state = FilterState();
      final updated = state.copyWith(
        showCompleted: false,
        priority: Priority.p1,
      );
      expect(updated.showCompleted, false);
      expect(updated.priority, Priority.p1);
      expect(updated.categoryId, null);
    });
  });

  group('FilterState.apply', () {
    test('returns non-archived tasks with default filter', () {
      const state = FilterState();
      final result = state.apply([task1, task2, task3]);
      expect(result.length, 2);
      expect(result, [task1, task2]);
    });

    test('hides completed when showCompleted is false', () {
      const state = FilterState(showCompleted: false);
      final result = state.apply([task1, task2]);
      expect(result, [task1]);
    });

    test('filters by priority', () {
      const state = FilterState(priority: Priority.p1);
      final result = state.apply([task1, task2]);
      expect(result, [task1]);
    });

    test('filters by category', () {
      const state = FilterState(categoryId: 'cat-1');
      final result = state.apply([task1, task2]);
      expect(result, [task1]);
    });

    test('hides archived when showArchived is false', () {
      const state = FilterState();
      final result = state.apply([task1, task3]);
      expect(result, [task1]);
    });

    test('shows archived when showArchived is true', () {
      const state = FilterState(showArchived: true);
      final result = state.apply([task1, task3]);
      expect(result.length, 2);
    });

    test('combines multiple filters', () {
      const state = FilterState(
        showCompleted: false,
        priority: Priority.p1,
        categoryId: 'cat-1',
      );
      final result = state.apply([task1, task2]);
      expect(result, [task1]);
    });
  });
}
