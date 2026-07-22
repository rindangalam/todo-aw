import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

final habitListProvider =
    StateNotifierProvider<HabitListNotifier, AsyncValue<List<Habit>>>((ref) {
  return HabitListNotifier(ref.read(habitRepositoryProvider));
});

final habitLogsProvider =
    FutureProvider.family<List<dynamic>, String>((ref, habitId) async {
  final repo = ref.read(habitRepositoryProvider);
  final logs = await repo.getLogs(habitId);
  final today = await repo.getTodayLog(habitId);
  return [logs, today];
});

final todayLoggedHabitIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.read(habitRepositoryProvider);
  final logs = await repo.getTodayLogs();
  return logs.map((l) => l.habitId).toSet();
});

class HabitListNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  final HabitRepository _repository;

  HabitListNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAll());
  }

  Future<void> create({
    required String name,
    String? description,
    int color = 0xFF5865F2,
    String? icon,
    HabitFrequency frequency = HabitFrequency.daily,
    int targetCount = 1,
  }) async {
    await _repository.create(
      name: name,
      description: description,
      color: color,
      icon: icon,
      frequency: frequency,
      targetCount: targetCount,
    );
    await load();
  }

  Future<void> update(Habit habit) async {
    await _repository.update(habit);
    await load();
  }

  Future<void> delete(String uuid) async {
    await _repository.delete(uuid);
    await load();
  }

  Future<void> toggleLog(String habitId) async {
    final todayLog = await _repository.getTodayLog(habitId);
    if (todayLog != null) {
      await _repository.unlogHabit(habitId);
    } else {
      await _repository.logHabit(habitId);
    }
    await load();
  }
}
