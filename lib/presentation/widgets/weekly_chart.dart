import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  final List<int> dailyCounts;
  final int maxCount;

  const WeeklyChart({
    super.key,
    required this.dailyCounts,
    this.maxCount = 0,
  });

  static const dayLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max =
        maxCount > 0 ? maxCount : dailyCounts.reduce((a, b) => a > b ? a : b);
    final effectiveMax = max < 1 ? 1 : max;

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final count = i < dailyCounts.length ? dailyCounts[i] : 0;
          final fraction = count / effectiveMax;
          final barHeight = fraction * 100;
          final clampedHeight = barHeight.clamp(0.0, 100.0);

          return Expanded(
            child: GestureDetector(
              onTap: count > 0
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${dayLabels[i]}: $count tugas'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (count > 0)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$count',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: clampedHeight),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, height, _) {
                        return Container(
                          width: double.infinity,
                          height: height.clamp(count > 0 ? 4.0 : 2.0, 100.0),
                          decoration: BoxDecoration(
                            color: count > 0
                                ? theme.colorScheme.primary
                                    .withOpacity(0.3 + fraction * 0.7)
                                : theme.colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dayLabels[i],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
