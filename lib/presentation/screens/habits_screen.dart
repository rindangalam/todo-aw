import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../data/models/habit.dart';
import '../../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_form_sheet.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(habitListProvider);
    final todayLoggedIdsAsync = ref.watch(todayLoggedHabitIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.habitTitle),
        centerTitle: false,
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${S.error}: $e')),
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.repeat_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.habitKosong,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.habitBuatPertama,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final loggedTodayIds = todayLoggedIdsAsync.valueOrNull ?? <String>{};
          final activeHabits =
              habits.where((h) => !h.isArchived).toList();
          final archivedHabits =
              habits.where((h) => h.isArchived).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
            children: [
              ...activeHabits.map((habit) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildHabitTile(habit, loggedTodayIds),
                  )),
              if (archivedHabits.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  S.taskArsipkan,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...archivedHabits.map((habit) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildHabitTile(habit, loggedTodayIds),
                    )),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showHabitFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitTile(Habit habit, Set<String> loggedTodayIds) {
    return HabitCard(
      habit: habit,
      isLoggedToday: loggedTodayIds.contains(habit.uuid),
      onTap: () => showHabitFormSheet(context, habitId: habit.uuid),
      onToggle: () =>
          ref.read(habitListProvider.notifier).toggleLog(habit.uuid),
    );
  }
}
