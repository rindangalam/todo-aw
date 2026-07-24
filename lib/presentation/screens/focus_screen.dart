import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/tokens.dart';
import '../../core/l10n/strings.dart';
import '../../data/models/task.dart';
import '../../providers/focus_provider.dart';
import '../../providers/task_list_provider.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusState = ref.watch(focusSessionProvider);
    final todayMinutes = ref.watch(focusTodayMinutesProvider);
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.focusTitle),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              todayMinutes.when(
                data: (m) => Text(
                  '${S.focusHariIni}: $m ${S.focusMenit}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                error: (_, __) => Text(
                  '${S.focusHariIni}: -- ${S.focusMenit}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                loading: () => const SizedBox(),
              ),
              const SizedBox(height: 32),
              // Timer ring
              SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(
                  painter: _TimerRingPainter(
                    progress: focusState.isRunning || focusState.isPaused
                        ? 1.0 -
                            focusState.remainingSeconds /
                                (focusState.durationMinutes * 60)
                        : 0,
                    color: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(focusState.remainingSeconds),
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          focusState.isPaused
                              ? S.focusJeda
                              : focusState.isRunning
                                  ? S.focusHariIni
                                  : '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Duration picker (only when not running)
              if (!focusState.isRunning)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [25, 15, 30, 50].map((m) {
                    final selected = focusState.durationMinutes == m;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text('$m'),
                        selected: selected,
                        onSelected: (_) => ref
                            .read(focusSessionProvider.notifier)
                            .setDuration(m),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),
              // Controls
              if (!focusState.isRunning && !focusState.isPaused)
                _buildStartButton(theme, tasksAsync)
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (focusState.isPaused)
                      _ControlButton(
                        icon: Icons.play_arrow,
                        label: S.focusLanjutkan,
                        color: ColorTokens.success,
                        onPressed: () =>
                            ref.read(focusSessionProvider.notifier).resume(),
                      )
                    else
                      _ControlButton(
                        icon: Icons.pause,
                        label: S.focusJeda,
                        color: ColorTokens.warning,
                        onPressed: () =>
                            ref.read(focusSessionProvider.notifier).pause(),
                      ),
                    const SizedBox(width: 16),
                    _ControlButton(
                      icon: Icons.stop,
                      label: S.batal,
                      color: ColorTokens.danger,
                      onPressed: () =>
                          ref.read(focusSessionProvider.notifier).stop(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(ThemeData theme, AsyncValue<List<Task>> tasksAsync) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: () => ref.read(focusSessionProvider.notifier).start(),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              S.focusMulai,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.15),
            foregroundColor: color,
            fixedSize: const Size(56, 56),
          ),
          iconSize: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2,
        2 * 3.14159 * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TimerRingPainter old) =>
      old.progress != progress || old.color != color;
}
