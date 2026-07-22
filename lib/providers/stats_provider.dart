import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_list_provider.dart';

class AppStats {
  final int totalTasks;
  final int completedTasks;
  final int streak;
  final Map<DateTime, int> completedPerDay;

  const AppStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.streak,
    required this.completedPerDay,
  });

  double get completionRate => totalTasks > 0 ? completedTasks / totalTasks : 0;
}

final statsProvider = FutureProvider<AppStats>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final allTasks = await repo.getAll();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final totalTasks = allTasks.length;
  final completedTasks = allTasks.where((t) => t.isCompleted).length;

  int streak = 0;
  var checkDate = today.subtract(const Duration(days: 1));
  final completedPerDay = <DateTime, int>{};

  for (final task in allTasks) {
    if (task.isCompleted) {
      final day = DateTime(
          task.updatedAt.year, task.updatedAt.month, task.updatedAt.day);
      completedPerDay[day] = (completedPerDay[day] ?? 0) + 1;
    }
  }

  while (completedPerDay.containsKey(checkDate)) {
    streak++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  }

  return AppStats(
    totalTasks: totalTasks,
    completedTasks: completedTasks,
    streak: streak,
    completedPerDay: completedPerDay,
  );
});
