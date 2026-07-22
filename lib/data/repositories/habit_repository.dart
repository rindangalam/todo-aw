import 'package:uuid/uuid.dart';

import '../database.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

class HabitRepository {
  final _uuid = const Uuid();

  Future<List<Habit>> getAll() => AppDatabase.getAllHabits();

  Future<Habit?> getById(String uuid) => AppDatabase.getHabit(uuid);

  Future<Habit> create({
    required String name,
    String? description,
    int color = 0xFF5865F2,
    String? icon,
    HabitFrequency frequency = HabitFrequency.daily,
    int targetCount = 1,
  }) async {
    final now = DateTime.now();
    final habit = Habit(
      uuid: _uuid.v4(),
      name: name,
      description: description,
      color: color,
      icon: icon,
      frequency: frequency,
      targetCount: targetCount,
      createdAt: now,
      updatedAt: now,
    );
    await AppDatabase.insertHabit(habit);
    return habit;
  }

  Future<void> update(Habit habit) async {
    await AppDatabase.updateHabit(habit.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> delete(String uuid) async {
    await AppDatabase.deleteHabit(uuid);
  }

  Future<List<HabitLog>> getLogs(String habitId) =>
      AppDatabase.getHabitLogs(habitId);

  Future<List<HabitLog>> getTodayLogs() =>
      AppDatabase.getHabitLogsByDate(DateTime.now());

  Future<HabitLog?> getTodayLog(String habitId) =>
      AppDatabase.getHabitLog(habitId, DateTime.now());

  Future<void> logHabit(String habitId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existing = await AppDatabase.getHabitLog(habitId, today);
    if (existing == null) {
      await AppDatabase.insertHabitLog(HabitLog(
        uuid: _uuid.v4(),
        habitId: habitId,
        date: today,
        createdAt: now,
      ));
      await _updateStreak(habitId);
    }
  }

  Future<void> unlogHabit(String habitId) async {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final existing = await AppDatabase.getHabitLog(habitId, day);
    if (existing != null) {
      await AppDatabase.deleteHabitLog(existing.uuid);
      await _updateStreak(habitId);
    }
  }

  Future<void> _updateStreak(String habitId) async {
    final habit = await AppDatabase.getHabit(habitId);
    if (habit == null) return;

    final logs = await AppDatabase.getHabitLogs(habitId);
    final completedDates = logs
        .where((l) => l.isCompleted)
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int currentStreak = 0;
    var checkDate = today;

    while (completedDates.contains(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    final longestStreak =
        currentStreak > habit.longestStreak ? currentStreak : habit.longestStreak;

    await AppDatabase.updateHabit(habit.copyWith(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    ));
  }
}
