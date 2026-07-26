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
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelect;
  final List<Color> tagColors;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDismiss,
    this.categoryColor,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelect,
    this.tagColors = const [],
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

    if (isSelectionMode) {
      return _buildSelectionCard(context, theme);
    }

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
      background: _buildSwipeBackground(),
      secondaryBackground: _buildSwipeSecondaryBackground(),
      child: _buildCardContent(context, theme),
    );
  }

  Widget _buildSelectionCard(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Card(
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          side: isSelected
              ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 22,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.4),
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
                      if (tagColors.isNotEmpty) _tagRow(),
                    ],
                  ),
                ),
                _priorityBadge(context, task.priority),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, ThemeData theme) {
    return Card(
      elevation: task.isCompleted ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: task.isCompleted
            ? BorderSide(
                color: theme.colorScheme.onSurface.withOpacity(0.08),
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _AnimatedCheckbox(
                value: task.isCompleted,
                onChanged: (v) {
                  HapticFeedback.lightImpact();
                  onToggle?.call(v);
                },
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
                    if (tagColors.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _tagRow(),
                    ],
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (task.dueDate != null) ...[
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _formatDate(task.dueDate!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
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
    );
  }

  Widget _tagRow() {
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: tagColors
          .map((c) => Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: ColorTokens.success,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Selesai',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeSecondaryBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: ColorTokens.danger,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Hapus',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 8),
          Icon(Icons.delete_outline, color: Colors.white, size: 20),
        ],
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
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _idnMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
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

class _AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnimatedCheckbox({required this.value, required this.onChanged});

  @override
  State<_AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<_AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    if (widget.value) _controller.value = 1;
  }

  @override
  void didUpdateWidget(_AnimatedCheckbox old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + _scaleAnim.value * 0.2,
            child: child,
          );
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.value
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            border: Border.all(
              color: widget.value
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: widget.value
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
