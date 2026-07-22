import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/tokens.dart';
import '../../core/l10n/strings.dart';
import '../../data/models/task.dart';
import 'category_dot.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onDismiss;
  final Color? categoryColor;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDismiss,
    this.categoryColor,
  });

  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.p1:
        return const Color(0xFFEF4444);
      case Priority.p2:
        return const Color(0xFFF59E0B);
      case Priority.p3:
        return const Color(0xFF3B82F6);
      case Priority.p4:
        return const Color(0xFF9CA3AF);
    }
  }

  String _priorityLabel(Priority priority) {
    switch (priority) {
      case Priority.p1:
        return 'P1';
      case Priority.p2:
        return 'P2';
      case Priority.p3:
        return 'P3';
      case Priority.p4:
        return 'P4';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(task.uuid),
      direction: DismissDirection.horizontal,
      movementDuration: const Duration(milliseconds: 200),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.lightImpact();
          onToggle?.call(!task.isCompleted);
          return false;
        } else {
          HapticFeedback.lightImpact();
          onDismiss?.call();
          return false;
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: ColorTokens.success,
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Selesai',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: ColorTokens.danger,
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hapus',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.delete_outline, color: Colors.white, size: 20),
          ],
        ),
      ),
      child: Hero(
        tag: 'task-${task.uuid}',
        child: Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child:                     Checkbox(
                      value: task.isCompleted,
                      onChanged: (v) {
                        HapticFeedback.lightImpact();
                        onToggle?.call(v ?? false);
                      },
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CategoryDot(color: categoryColor, size: 10),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? theme.colorScheme.onSurface.withOpacity(0.4)
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (task.dueDate != null) ...[
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _formatDate(task.dueDate!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            _priorityBadge(context, task.priority),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _priorityBadge(BuildContext context, Priority priority) {
    final color = _priorityColor(priority);
    final label = _priorityLabel(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  static const _idnDays = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const _idnMonths = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return S.hariIni;
    if (taskDate == today.add(const Duration(days: 1))) return S.besok;
    if (taskDate.isAfter(today) &&
        taskDate.isBefore(today.add(const Duration(days: 7)))) {
      return _idnDays[date.weekday - 1];
    }
    return '${_idnMonths[date.month - 1]} ${date.day}';
  }
}
