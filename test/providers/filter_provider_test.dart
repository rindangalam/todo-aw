import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/providers/filter_provider.dart';

void main() {
  group('FilterNotifier', () {
    test('initial state has no filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(filterProvider);
      expect(state.showCompleted, true);
      expect(state.priority, null);
      expect(state.categoryId, null);
      expect(state.isActive, false);
    });

    test('toggleShowCompleted flips the value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(filterProvider.notifier).toggleShowCompleted();
      expect(container.read(filterProvider).showCompleted, false);

      container.read(filterProvider.notifier).toggleShowCompleted();
      expect(container.read(filterProvider).showCompleted, true);
    });

    test('setPriority toggles the same priority off', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(filterProvider.notifier).setPriority(Priority.p1);
      expect(container.read(filterProvider).priority, Priority.p1);

      container.read(filterProvider.notifier).setPriority(Priority.p1);
      expect(container.read(filterProvider).priority, null);
    });

    test('setCategory toggles the same category off', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(filterProvider.notifier).setCategory('cat-1');
      expect(container.read(filterProvider).categoryId, 'cat-1');

      container.read(filterProvider.notifier).setCategory('cat-1');
      expect(container.read(filterProvider).categoryId, null);
    });

    test('toggleShowArchived flips the value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(filterProvider.notifier).toggleShowArchived();
      expect(container.read(filterProvider).showArchived, true);

      container.read(filterProvider.notifier).toggleShowArchived();
      expect(container.read(filterProvider).showArchived, false);
    });

    test('reset restores defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(filterProvider.notifier).setPriority(Priority.p1);
      container.read(filterProvider.notifier).setCategory('cat-1');
      container.read(filterProvider.notifier).toggleShowCompleted();
      container.read(filterProvider.notifier).reset();

      final state = container.read(filterProvider);
      expect(state.showCompleted, true);
      expect(state.priority, null);
      expect(state.categoryId, null);
    });

    test('isActive reflects any active filter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(filterProvider).isActive, false);

      container.read(filterProvider.notifier).toggleShowCompleted();
      expect(container.read(filterProvider).isActive, true);
    });
  });
}
