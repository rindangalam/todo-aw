import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/providers/search_provider.dart';
import 'package:todoaw/providers/task_list_provider.dart';
import 'package:todoaw/data/repositories/task_repository.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository mockRepo;
  late DateTime now;

  setUp(() {
    mockRepo = MockTaskRepository();
    now = DateTime(2026, 7, 20);
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  group('SearchNotifier', () {
    test('initial state is empty data', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(searchProvider);
      expect(state, isA<AsyncValue<List<Task>>>());
      expect(state.hasValue, true);
      expect(state.value, isEmpty);
    });

    test('returns empty results for empty query', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(searchProvider.notifier).search('');
      final state1 = container.read(searchProvider);
      expect(state1.hasValue, true);
      expect(state1.value, isEmpty);

      container.read(searchProvider.notifier).search('   ');
      final state2 = container.read(searchProvider);
      expect(state2.hasValue, true);
      expect(state2.value, isEmpty);
    });

    test('searches after debounce delay', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      when(() => mockRepo.search('milk')).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Buy milk',
              createdAt: now,
              updatedAt: now,
            ),
          ]);

      container.read(searchProvider.notifier).search('milk');
      expect(
        container.read(searchProvider).hasValue,
        true,
      );

      await Future.delayed(const Duration(milliseconds: 350));
      final state = container.read(searchProvider);
      expect(state.hasValue, true);
      expect(state.value!.length, 1);
      expect(state.value!.first.title, 'Buy milk');

      verify(() => mockRepo.search('milk')).called(1);
    });

    test('cancels previous debounce on new query', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      when(() => mockRepo.search('old')).thenAnswer((_) async => []);
      when(() => mockRepo.search('new')).thenAnswer((_) async => [
            Task(
              uuid: '2',
              title: 'New task',
              createdAt: now,
              updatedAt: now,
            ),
          ]);

      container.read(searchProvider.notifier).search('old');
      container.read(searchProvider.notifier).search('new');

      await Future.delayed(const Duration(milliseconds: 350));
      final state = container.read(searchProvider);
      expect(state.value!.length, 1);
      expect(state.value!.first.title, 'New task');

      verifyNever(() => mockRepo.search('old'));
      verify(() => mockRepo.search('new')).called(1);
    });
  });
}
