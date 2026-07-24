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
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onToggle?.call();
        },
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _AnimatedCheckCircle(
                isLogged: isLoggedToday,
                color: color,
                onToggle: () {
                  HapticFeedback.lightImpact();
                  onToggle?.call();
                },
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
                      const _StreakFlame(size: 12),
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

class _AnimatedCheckCircle extends StatefulWidget {
  final bool isLogged;
  final Color color;
  final VoidCallback onToggle;

  const _AnimatedCheckCircle({
    required this.isLogged,
    required this.color,
    required this.onToggle,
  });

  @override
  State<_AnimatedCheckCircle> createState() => _AnimatedCheckCircleState();
}

class _AnimatedCheckCircleState extends State<_AnimatedCheckCircle>
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
    if (widget.isLogged) _controller.value = 1;
  }

  @override
  void didUpdateWidget(_AnimatedCheckCircle old) {
    super.didUpdateWidget(old);
    if (widget.isLogged != old.isLogged) {
      if (widget.isLogged) {
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
      onTap: widget.onToggle,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + _scaleAnim.value * 0.2,
            child: child,
          );
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isLogged ? widget.color : Colors.transparent,
            border: Border.all(
              color:
                  widget.isLogged ? widget.color : widget.color.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: widget.isLogged
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
      ),
    );
  }
}

class _StreakFlame extends StatefulWidget {
  final double size;

  const _StreakFlame({this.size = 12});

  @override
  State<_StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<_StreakFlame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnim.value,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(
          Icons.local_fire_department,
          size: widget.size,
          color: ColorTokens.warning,
        ),
      ),
    );
  }
}
