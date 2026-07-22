import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/providers/task_list_provider.dart';
import 'package:todoaw/data/repositories/task_repository.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTaskRepository mockRepo;
  late DateTime now;

  setUpAll(() {
    registerFallbackValue(Task(
      uuid: 'fallback',
      title: '',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    ));
  });

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

  group('TaskListNotifier', () {
    test('loads tasks on initialization', () async {
      when(() => mockRepo.getActive()).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Task 1',
              createdAt: now,
              updatedAt: now,
            ),
          ]);

      final container = createContainer();
      addTearDown(container.dispose);

      // Trigger provider creation, then wait for async load
      container.read(taskListProvider);
      await container.read(taskListProvider.notifier).load();

      final state = container.read(taskListProvider);
      expect(state.hasValue, true);
      expect(state.value!.length, 1);
      expect(state.value!.first.title, 'Task 1');
    });

    test('toggleComplete flips isCompleted and reloads', () async {
      final task = Task(
        uuid: '1',
        title: 'Test',
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
      when(() => mockRepo.getActive()).thenAnswer((_) async => [task]);
      when(() => mockRepo.update(any())).thenAnswer((_) async => {});

      final container = createContainer();
      addTearDown(container.dispose);

      container.read(taskListProvider);
      await container.read(taskListProvider.notifier).load();
      await container.read(taskListProvider.notifier).toggleComplete(task);

      verify(() => mockRepo.update(any())).called(1);
    });

    test('softDelete calls repository softDelete', () async {
      // Silence flutter_local_notifications plugin channel
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        (_) async => null,
      );

      final task = Task(
        uuid: '1',
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );
      when(() => mockRepo.getActive()).thenAnswer((_) async => [task]);
      when(() => mockRepo.softDelete(any())).thenAnswer((_) async => {});

      final container = createContainer();
      addTearDown(container.dispose);

      container.read(taskListProvider);
      await container.read(taskListProvider.notifier).load();
      await container.read(taskListProvider.notifier).softDelete(task);

      verify(() => mockRepo.softDelete(task.uuid)).called(1);
    });

    test('archive updates task and reloads', () async {
      final task = Task(
        uuid: '1',
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );
      when(() => mockRepo.getActive()).thenAnswer((_) async => [task]);
      when(() => mockRepo.update(any())).thenAnswer((_) async => {});

      final container = createContainer();
      addTearDown(container.dispose);

      container.read(taskListProvider);
      await container.read(taskListProvider.notifier).load();
      await container.read(taskListProvider.notifier).archive(task);

      verify(() => mockRepo.update(any())).called(1);
    });
  });
}
