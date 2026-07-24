import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../core/design/tokens.dart';
import '../../core/l10n/strings.dart';
import '../../data/models/filter_state.dart';
import '../../data/models/task.dart';
import '../../providers/category_provider.dart';
import '../../providers/filter_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/selection_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/tag_provider.dart';
import '../widgets/error_state.dart';
import '../../providers/task_list_provider.dart';
import '../../services/tour_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/home_hero.dart';
import '../widgets/task_card.dart';
import '../widgets/tour_card.dart';
import 'task_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();
  final _heroKey = GlobalKey();
  final _quickActionsKey = GlobalKey();
  final _filterKey = GlobalKey();
  final _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCoachmark());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initCoachmark() async {
    if (!mounted) return;
    final seen = await TourService.isCoachmarkHomeSeen();
    if (seen || !mounted) return;

    final targets = [
      TargetFocus(
        identify: 'hero',
        keyTarget: _heroKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => TourCard(
              title: 'Progress Hari Ini',
              body:
                  'Lihat tugas hari ini, berapa yang udah selesai, dan streak produktivitasmu.',
              onNext: controller.next,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'quick_actions',
        keyTarget: _quickActionsKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => TourCard(
              title: 'Akses Cepat',
              body:
                  'Pengen cepet-cepet? Langsung tambah tugas, catatan, '
                  'fokus, atau kebiasaan dari sini.',
              onNext: controller.next,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'filter',
        keyTarget: _filterKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => TourCard(
              title: 'Filter & Cari',
              body:
                  'Tugas numpuk? Filter prioritas, kategori, atau status. '
                  'Mau nyari? Tinggal tap ikon kaca pembesar.',
              onNext: controller.next,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'fab',
        keyTarget: _fabKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => TourCard(
              title: 'Tambah Tugas',
              body:
                  'Tap + buat tugas baru. Geser kanan kalau selesai, '
                  'geser kiri kalau mau hapus. Gampang.',
              onNext: controller.next,
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black87,
      paddingFocus: 8,
      pulseEnable: true,
      onClickTarget: (target) {
        if (target.identify == 'fab') {
          TourService.markCoachmarkHomeSeen();
        }
      },
      onClickOverlay: (target) {
        if (target.identify == 'fab') {
          TourService.markCoachmarkHomeSeen();
        }
      },
      onFinish: () => TourService.markCoachmarkHomeSeen(),
      onSkip: () {
        TourService.markCoachmarkHomeSeen();
        return true;
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);
    final filter = ref.watch(filterProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final statsAsync = ref.watch(statsProvider);
    final searchResults = ref.watch(searchProvider);
    final selection = ref.watch(selectionProvider);
    final taskTagMapAsync = ref.watch(taskTagMapProvider);
    final tagsAsync = ref.watch(tagListProvider);

    final categoryColors = categoriesAsync.valueOrNull != null
        ? {for (final c in categoriesAsync.valueOrNull!) c.uuid: c.color}
        : <String, int>{};
    final taskTagMap = taskTagMapAsync.valueOrNull ?? <String, Set<String>>{};
    final tagColorMap = tagsAsync.valueOrNull != null
        ? {for (final t in tagsAsync.valueOrNull!) t.uuid: t.color}
        : <String, int>{};

    return Scaffold(
      body: Stack(
        children: [
          tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorState(
              detail: e.toString(),
              onRetry: () => ref.read(taskListProvider.notifier).load(),
            ),
            data: (tasks) {
              final hasQuery =
                  _showSearch && _searchController.text.trim().isNotEmpty;
              final effectiveTasks =
                  hasQuery ? (searchResults.valueOrNull ?? tasks) : tasks;
              final filtered =
                  filter.apply(effectiveTasks, taskTagMap: taskTagMap);
              final grouped = _groupTasks(filtered);

              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final todayTasks =
                  tasks.where((t) => _isSameDay(t.dueDate, today)).toList();
              final todayCompleted =
                  todayTasks.where((t) => t.isCompleted).length;
              final streak = statsAsync.valueOrNull?.streak ?? 0;

              return RefreshIndicator(
                onRefresh: () => ref.read(taskListProvider.notifier).refresh(),
                child: ListView(
                  padding: EdgeInsets.only(
                    bottom: selection.isActive ? 80 : 80,
                  ),
                  children: [
                    if (!selection.isActive)
                      HomeHero(
                        key: _heroKey,
                        quickActionsKey: _quickActionsKey,
                        todayTotal: todayTasks.length,
                        todayCompleted: todayCompleted,
                        streak: streak,
                      ),
                    _buildSelectionBar(context, selection),
                    if (!selection.isActive) _buildSearchBar(context),
                    if (!selection.isActive)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            Spacing.md, Spacing.sm, Spacing.md, 0),
                        child: Row(
                          children: [
                            Text(
                              _showSearch ? S.searchHasil : S.homeDaftarTugas,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            SizedBox(
                                key: _filterKey,
                                child: _FilterAction(filter: filter, ref: ref)),
                          ],
                        ),
                      ),
                    if (filtered.isEmpty && !selection.isActive)
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: _buildEmptyState(filter, context),
                      )
                    else
                      ...grouped.entries.map((entry) => _TaskSection(
                            label: entry.key,
                            tasks: entry.value,
                            ref: ref,
                            categoryColors: categoryColors,
                            selection: selection,
                            taskTagMap: taskTagMap,
                            tagColorMap: tagColorMap,
                          )),
                  ],
                ),
              );
            },
          ),
          if (selection.isActive)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildSelectionBottomBar(context, selection),
            ),
        ],
      ),
      floatingActionButton: selection.isActive
          ? null
          : FloatingActionButton(
              key: _fabKey,
              onPressed: () => showTaskFormSheet(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildSelectionBar(BuildContext context, SelectionState selection) {
    if (!selection.isActive) return const SizedBox.shrink();
    final allUuids = ref.read(taskListProvider).valueOrNull ?? [];
    final allVisible = allUuids.map((t) => t.uuid).toSet();
    final allSelected =
        selection.selectedIds.containsAll(allVisible) && allVisible.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, 0),
      child: Row(
        children: [
          Text(
            '${selection.selectedIds.length} dipilih',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              if (allSelected) {
                ref.read(selectionProvider.notifier).clearSelection();
              } else {
                ref.read(selectionProvider.notifier).selectAll(allVisible);
              }
            },
            icon: Icon(
              allSelected ? Icons.deselect : Icons.select_all,
              size: 18,
            ),
            label: Text(allSelected ? 'Batalkan Semua' : 'Pilih Semua'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBottomBar(
      BuildContext context, SelectionState selection) {
    final theme = Theme.of(context);
    final count = selection.selectedIds.length;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionButton(
              context,
              icon: Icons.check_circle_outline,
              label: 'Selesai',
              color: ColorTokens.success,
              onTap: () async {
                await ref
                    .read(taskListProvider.notifier)
                    .batchComplete(selection.selectedIds);
                ref.read(selectionProvider.notifier).exitSelectionMode();
              },
            ),
            _actionButton(
              context,
              icon: Icons.archive_outlined,
              label: 'Arsip',
              color: ColorTokens.primary,
              onTap: () async {
                await ref
                    .read(taskListProvider.notifier)
                    .batchArchive(selection.selectedIds);
                ref.read(selectionProvider.notifier).exitSelectionMode();
              },
            ),
            _actionButton(
              context,
              icon: Icons.delete_outline,
              label: 'Hapus',
              color: ColorTokens.danger,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Hapus $count tugas?'),
                    content:
                        const Text('Tugas akan dipindahkan ke tempat sampah.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref
                      .read(taskListProvider.notifier)
                      .batchDelete(selection.selectedIds);
                  ref.read(selectionProvider.notifier).exitSelectionMode();
                }
              },
            ),
            _actionButton(
              context,
              icon: Icons.close,
              label: 'Batal',
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              onTap: () =>
                  ref.read(selectionProvider.notifier).exitSelectionMode(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, 0),
      child: Row(
        children: [
          Expanded(
            child: _showSearch
                ? SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: S.searchHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(RadiusTokens.sm),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor:
                            theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                      onChanged: (q) =>
                          ref.read(searchProvider.notifier).search(q),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (!_showSearch)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: InkWell(
                onTap: () => setState(() => _showSearch = true),
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(RadiusTokens.sm),
                  ),
                  child: const Icon(Icons.search, size: 22),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: InkWell(
                onTap: () {
                  setState(() => _showSearch = false);
                  _searchController.clear();
                  ref.read(searchProvider.notifier).search('');
                },
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(RadiusTokens.sm),
                  ),
                  child: const Icon(Icons.close, size: 22),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(FilterState filter, BuildContext context) {
    return EmptyState(
      icon: filter.isActive ? Icons.filter_alt_off : Icons.checklist_rtl,
      title: filter.isActive ? S.filterTidakCocok : S.homeTidakAdaTugas,
      subtitle: filter.isActive ? S.filterUbahFilter : S.homeBuatTugasPertama,
      actionLabel: filter.isActive ? null : S.quickTambahTugas,
      onAction: filter.isActive ? null : () => showTaskFormSheet(context),
    );
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Map<String, List<Task>> _groupTasks(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final grouped = <String, List<Task>>{};
    for (final task in tasks) {
      String key;
      if (task.dueDate == null) {
        key = S.taskTanpaTanggal;
      } else {
        final d = DateTime(
            task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        if (d == today) {
          key = S.hariIni;
        } else if (d == tomorrow) {
          key = S.besok;
        } else {
          key = DateFormat('MMMM d').format(task.dueDate!);
        }
      }
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(task);
    }

    final ordered = <String, List<Task>>{};
    if (grouped.containsKey(S.hariIni)) {
      ordered[S.hariIni] = grouped[S.hariIni]!;
    }
    if (grouped.containsKey(S.besok)) {
      ordered[S.besok] = grouped[S.besok]!;
    }
    for (final key in grouped.keys) {
      if (key != S.hariIni && key != S.besok) {
        ordered[key] = grouped[key]!;
      }
    }
    return ordered;
  }
}

class _FilterAction extends StatelessWidget {
  final FilterState filter;
  final WidgetRef ref;

  const _FilterAction({required this.filter, required this.ref});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (!filter.showCompleted) {
      chips.add(_chip(context, S.filterTampilkanSelesai, () {
        ref.read(filterProvider.notifier).toggleShowCompleted();
      }));
    }
    if (filter.priority != null) {
      chips.add(_chip(context, filter.priority!.name.toUpperCase(), () {
        ref.read(filterProvider.notifier).setPriority(filter.priority);
      }));
    }
    if (filter.categoryId != null) {
      chips.add(_chip(context, S.filterKategori, () {
        ref.read(filterProvider.notifier).setCategory(filter.categoryId);
      }));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionChip(
          avatar: Icon(
            Icons.filter_list,
            size: 16,
            color:
                filter.isActive ? Theme.of(context).colorScheme.primary : null,
          ),
          label: const Text(S.filterTitle),
          onPressed: () => showFilterSheet(context),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            );
          },
          child: chips.isNotEmpty
              ? Row(
                  key: const ValueKey('chips'),
                  mainAxisSize: MainAxisSize.min,
                  children: chips,
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _TaskSection extends StatelessWidget {
  final String label;
  final List<Task> tasks;
  final WidgetRef ref;
  final Map<String, int> categoryColors;
  final SelectionState selection;
  final Map<String, Set<String>> taskTagMap;
  final Map<String, int> tagColorMap;

  const _TaskSection({
    required this.label,
    required this.tasks,
    required this.ref,
    required this.categoryColors,
    required this.selection,
    required this.taskTagMap,
    this.tagColorMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!selection.isActive)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.md, Spacing.md, Spacing.md, 4),
            child: Text(
              _sectionLabel(label),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ...tasks.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          final anim = TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: Spacing.md,
                right: Spacing.md,
                bottom: index == tasks.length - 1 ? Spacing.xs : 0,
              ),
              child: TaskCard(
                task: task,
                categoryColor: task.categoryId != null
                    ? Color(categoryColors[task.categoryId] ?? 0xFF9CA3AF)
                    : null,
                tagColors: (taskTagMap[task.uuid] ?? <String>{})
                    .map((tid) => Color(tagColorMap[tid] ?? 0xFF6366F1))
                    .toList(),
                isSelectionMode: selection.isActive,
                isSelected: selection.selectedIds.contains(task.uuid),
                onSelect: () =>
                    ref.read(selectionProvider.notifier).toggle(task.uuid),
                onTap: selection.isActive
                    ? () =>
                        ref.read(selectionProvider.notifier).toggle(task.uuid)
                    : () => showTaskFormSheet(context, taskId: task.uuid),
                onToggle: selection.isActive
                    ? null
                    : (_) => ref
                        .read(taskListProvider.notifier)
                        .toggleComplete(task),
                onDismiss: selection.isActive
                    ? null
                    : () =>
                        ref.read(taskListProvider.notifier).softDelete(task),
              ),
            ),
          );
          // Wrap with long-press handler
          return GestureDetector(
            key: ValueKey(task.uuid),
            onLongPress: () {
              if (!selection.isActive) {
                ref
                    .read(selectionProvider.notifier)
                    .enterSelectionMode(task.uuid);
              }
            },
            child: anim,
          );
        }),
      ],
    );
  }

  String _sectionLabel(String key) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (key == S.hariIni) {
      return '${S.hariIni} — ${DateFormat('d MMM').format(today)}';
    }
    if (key == S.besok) {
      return '${S.besok} — ${DateFormat('d MMM').format(tomorrow)}';
    }
    return key;
  }
}
