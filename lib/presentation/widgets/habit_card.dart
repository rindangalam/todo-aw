import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/tokens.dart';
import '../../data/models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isLoggedToday;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const HabitCard({
    super.key,
    required this.habit,
    this.isLoggedToday = false,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(habit.color);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggle?.call();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLoggedToday ? color : Colors.transparent,
                    border: Border.all(
                      color: isLoggedToday ? color : color.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: isLoggedToday
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _frequencyLabel(habit.frequency),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: habit.currentStreak > 0
                      ? ColorTokens.warning.withOpacity(0.15)
                      : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (habit.currentStreak > 0)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.local_fire_department,
                            size: 12, color: ColorTokens.warning),
                      ),
                    Text(
                      '${habit.currentStreak}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: habit.currentStreak > 0
                            ? ColorTokens.warning
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _frequencyLabel(HabitFrequency freq) {
    switch (freq) {
      case HabitFrequency.daily:
        return 'Harian';
      case HabitFrequency.weekly:
        return 'Mingguan';
      case HabitFrequency.monthly:
        return 'Bulanan';
    }
  }
}
