import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/tokens.dart';
import '../../core/l10n/strings.dart';
import '../../data/models/task.dart';
import '../../providers/stats_provider.dart';
import '../../providers/task_list_provider.dart';
import '../widgets/progress_ring.dart';
import '../widgets/weekly_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(statsProvider);
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.dashboardTitle),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodayProgress(theme, tasksAsync),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, S.dashboardProduktivitas),
            const SizedBox(height: 8),
            _buildWeeklyChart(theme, statsAsync),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, S.dashboardStatistik),
            const SizedBox(height: 8),
            _buildStatsRow(theme, statsAsync),
            const SizedBox(height: 24),
            if (statsAsync.valueOrNull != null)
              _buildStreakSection(theme, statsAsync.valueOrNull!.streak),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTodayProgress(
      ThemeData theme, AsyncValue<List<Task>> tasksAsync) {
    final tasks = tasksAsync.valueOrNull ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayTasks = tasks.where((t) {
      if (t.dueDate == null) return false;
      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return d == today;
    }).toList();

    final completed = todayTasks.where((t) => t.isCompleted).length;
    final total = todayTasks.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            ProgressRing(
              progress: progress,
              size: 72,
              strokeWidth: 5,
              color: progress >= 1.0 && total > 0
                  ? ColorTokens.success
                  : ColorTokens.primary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.dashboardProgressHariIni,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed/$total ${S.homeTugasHariIni}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      color: progress >= 1.0 && total > 0
                          ? ColorTokens.success
                          : ColorTokens.primary,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(
      ThemeData theme, AsyncValue<AppStats> statsAsync) {
    final stats = statsAsync.valueOrNull;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final dailyCounts = List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      return stats?.completedPerDay[day] ?? 0;
    });

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                S.dashboardTargetMingguan,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
            WeeklyChart(dailyCounts: dailyCounts),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(
      ThemeData theme, AsyncValue<AppStats> statsAsync) {
    final stats = statsAsync.valueOrNull;
    final total = stats?.totalTasks ?? 0;
    final completed = stats?.completedTasks ?? 0;
    final active = total - completed;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: S.dashboardTotalAktif,
            value: '$active',
            icon: Icons.pending_actions,
            color: ColorTokens.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: S.dashboardTotalSelesai,
            value: '$completed',
            icon: Icons.check_circle_outline,
            color: ColorTokens.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: S.dashboardTotal,
            value: '$total',
            icon: Icons.inbox_outlined,
            color: ColorTokens.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakSection(ThemeData theme, int streak) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ColorTokens.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: ColorTokens.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak ${S.homeStreak}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  streak > 0
                      ? '${streak == 1 ? 'Kemarin' : '$streak hari berturut-turut'} aktif'
                      : 'Mulai streak-mu hari ini!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
