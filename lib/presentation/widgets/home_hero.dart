import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/tokens.dart';
import '../../core/l10n/strings.dart';
import '../../providers/task_list_provider.dart';
import '../screens/task_form_screen.dart';
import 'progress_ring.dart';

class HomeHero extends StatelessWidget {
  final int todayTotal;
  final int todayCompleted;
  final int streak;
  final GlobalKey? quickActionsKey;

  const HomeHero({
    super.key,
    required this.todayTotal,
    required this.todayCompleted,
    required this.streak,
    this.quickActionsKey,
  });

  double get _progress => todayTotal > 0 ? todayCompleted / todayTotal : 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  ColorTokens.darkSurface,
                  ColorTokens.darkBackground,
                ]
              : [
                  ColorTokens.primary.withOpacity(0.08),
                  ColorTokens.primary.withOpacity(0.02),
                ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(RadiusTokens.lg),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Spacing.lg, Spacing.lg, Spacing.lg, Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GreetingRow(streak: streak),
            const SizedBox(height: Spacing.lg),
            _ProgressSection(
              progress: _progress,
              todayCompleted: todayCompleted,
              todayTotal: todayTotal,
            ),
            const SizedBox(height: Spacing.lg),
            _QuickActions(key: quickActionsKey),
          ],
        ),
      ),
    );
  }
}

class _TemplatePickerSheet extends ConsumerWidget {
  const _TemplatePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templateListProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(S.templatePilih,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: templatesAsync.when(
                data: (templates) {
                  if (templates.isEmpty) {
                    return const Center(child: Text(S.templateBelumAda));
                  }
                  return ListView.separated(
                    controller: scrollController,
                    itemCount: templates.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final t = templates[i];
                      return ListTile(
                        title: Text(t.title),
                        subtitle:
                            t.description != null && t.description!.isNotEmpty
                                ? Text(t.description!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)
                                : null,
                        leading: const Icon(Icons.bookmark,
                            color: Color(0xFF8B5CF6)),
                        onTap: () async {
                          Navigator.pop(context);
                          await ref
                              .read(taskListProvider.notifier)
                              .createFromTemplate(t.uuid);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Gagal memuat: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingRow extends StatefulWidget {
  final int streak;

  const _GreetingRow({required this.streak});

  @override
  State<_GreetingRow> createState() => _GreetingRowState();
}

class _GreetingRowState extends State<_GreetingRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _greetingWithWave() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return '${S.greetingPagi} \u{1F44B}';
    } else if (hour < 15) {
      return '${S.greetingSiang} \u{1F44B}';
    } else if (hour < 18) {
      return '${S.greetingSore} \u{1F44B}';
    }
    return '${S.greetingMalam} \u{1F44B}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                _greetingWithWave(),
                key: ValueKey(DateTime.now().hour),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              S.appTagline,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        if (widget.streak > 0)
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnim.value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm, vertical: Spacing.xxs),
              decoration: BoxDecoration(
                color: ColorTokens.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department,
                      size: 16, color: ColorTokens.warning),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.streak} ${S.homeStreak}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ColorTokens.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final double progress;
  final int todayCompleted;
  final int todayTotal;

  const _ProgressSection({
    required this.progress,
    required this.todayCompleted,
    required this.todayTotal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        ProgressRing(
          progress: progress,
          size: 72,
          strokeWidth: 5,
          color: progress >= 1.0 ? ColorTokens.success : ColorTokens.primary,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.homeTugasHariIni,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.xxs),
              Row(
                children: [
                  _StatBadge(
                    icon: Icons.check_circle,
                    value: '$todayCompleted',
                    label: S.homeSelesai,
                    color: ColorTokens.success,
                  ),
                  const SizedBox(width: Spacing.md),
                  _StatBadge(
                    icon: Icons.radio_button_unchecked,
                    value: '${todayTotal - todayCompleted}',
                    label: S.homeTersisa,
                    color: ColorTokens.warning,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.checklist,
            label: S.quickTambahTugas,
            color: ColorTokens.primary,
            onTap: () => showTaskFormSheet(context),
          ),
        ),
        Expanded(
          child: _ActionButton(
            icon: Icons.bookmark,
            label: S.quickDariTemplate,
            color: const Color(0xFF8B5CF6),
            onTap: () => _showTemplatePicker(context),
          ),
        ),
        Expanded(
          child: _ActionButton(
            icon: Icons.lightbulb_outline,
            label: S.quickTambahCatatan,
            color: ColorTokens.secondary,
            onTap: () => context.push('/notes'),
          ),
        ),
        Expanded(
          child: _ActionButton(
            icon: Icons.timer_outlined,
            label: S.quickMulaiFokus,
            color: ColorTokens.success,
            onTap: () => context.push('/focus'),
          ),
        ),
        Expanded(
          child: _ActionButton(
            icon: Icons.repeat,
            label: S.quickTambahKebiasaan,
            color: ColorTokens.warning,
            onTap: () => context.push('/habits'),
          ),
        ),
      ],
    );
  }

  void _showTemplatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(RadiusTokens.lg)),
      ),
      builder: (_) => const _TemplatePickerSheet(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadiusTokens.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(RadiusTokens.sm),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
