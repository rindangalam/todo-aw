import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/providers/stats_provider.dart';
import 'package:todoaw/providers/task_list_provider.dart';
import 'package:todoaw/data/repositories/task_repository.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository mockRepo;

  setUp(() {
    mockRepo = MockTaskRepository();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  group('statsProvider', () {
    test('returns zeros when no tasks exist', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => []);

      final container = createContainer();
      addTearDown(container.dispose);

      final stats = await container.read(statsProvider.future);
      expect(stats.totalTasks, 0);
      expect(stats.completedTasks, 0);
      expect(stats.streak, 0);
      expect(stats.completionRate, 0.0);
    });

    test('calculates completion rate correctly', () async {
      final yesterday = DateTime(2026, 7, 19, 10, 0, 0);
      when(() => mockRepo.getAll()).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Done',
              isCompleted: true,
              createdAt: yesterday,
              updatedAt: yesterday,
            ),
            Task(
              uuid: '2',
              title: 'Pending',
              isCompleted: false,
              createdAt: yesterday,
              updatedAt: yesterday,
            ),
          ]);

      final container = createContainer();
      addTearDown(container.dispose);

      final stats = await container.read(statsProvider.future);
      expect(stats.totalTasks, 2);
      expect(stats.completedTasks, 1);
      expect(stats.completionRate, 0.5);
    });

    test('calculates streak correctly', () async {
      final twoDaysAgo = DateTime(2026, 7, 18, 10, 0, 0);
      final oneDayAgo = DateTime(2026, 7, 19, 10, 0, 0);
      when(() => mockRepo.getAll()).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Old',
              isCompleted: true,
              createdAt: twoDaysAgo,
              updatedAt: twoDaysAgo,
            ),
            Task(
              uuid: '2',
              title: 'Yesterday',
              isCompleted: true,
              createdAt: oneDayAgo,
              updatedAt: oneDayAgo,
            ),
          ]);

      final container = createContainer();
      addTearDown(container.dispose);

      final stats = await container.read(statsProvider.future);
      expect(stats.streak, 2);
    });

    test('streak breaks on days without completions', () async {
      final threeDaysAgo = DateTime(2026, 7, 17, 10, 0, 0);
      final oneDayAgo = DateTime(2026, 7, 19, 10, 0, 0);
      when(() => mockRepo.getAll()).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Old',
              isCompleted: true,
              createdAt: threeDaysAgo,
              updatedAt: threeDaysAgo,
            ),
            Task(
              uuid: '2',
              title: 'Yesterday',
              isCompleted: true,
              createdAt: oneDayAgo,
              updatedAt: oneDayAgo,
            ),
          ]);

      final container = createContainer();
      addTearDown(container.dispose);

      final stats = await container.read(statsProvider.future);
      // No completions on July 18, so streak is 1 (only yesterday)
      expect(stats.streak, 1);
    });
  });
}
