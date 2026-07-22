import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/models/habit.dart';
import 'package:todoaw/data/repositories/habit_repository.dart';

import '../test_helpers.dart';

void main() {
  late HabitRepository repo;

  setUpAll(() {
    setupTestDatabase();
  });

  setUp(() async {
    await initTestDb();
    repo = HabitRepository();
  });

  tearDown(() async {
    await closeTestDb();
  });

  group('HabitRepository', () {
    test('create and getAll', () async {
      final habit = await repo.create(name: 'Minum Air');
      expect(habit.name, 'Minum Air');
      expect(habit.frequency, HabitFrequency.daily);

      final all = await repo.getAll();
      expect(all.any((h) => h.uuid == habit.uuid), true);
    });

    test('getById returns null for missing', () async {
      final result = await repo.getById('nonexistent');
      expect(result, isNull);
    });

    test('update modifies habit', () async {
      final habit = await repo.create(name: 'Original');
      await repo.update(habit.copyWith(name: 'Updated'));
      final updated = await repo.getById(habit.uuid);
      expect(updated?.name, 'Updated');
    });

    test('delete removes habit', () async {
      final habit = await repo.create(name: 'To Delete');
      await repo.delete(habit.uuid);
      final result = await repo.getById(habit.uuid);
      expect(result, isNull);
    });

    test('logHabit creates log and updates streak', () async {
      final habit = await repo.create(name: 'Exercise');
      await repo.logHabit(habit.uuid);

      final todayLog = await repo.getTodayLog(habit.uuid);
      expect(todayLog, isNotNull);
      expect(todayLog!.habitId, habit.uuid);

      final updated = await repo.getById(habit.uuid);
      expect(updated!.currentStreak, 1);
    });

    test('unlogHabit removes today log', () async {
      final habit = await repo.create(name: 'Exercise');
      await repo.logHabit(habit.uuid);
      await repo.unlogHabit(habit.uuid);

      final todayLog = await repo.getTodayLog(habit.uuid);
      expect(todayLog, isNull);
    });
  });
}
