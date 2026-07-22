import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/design/tokens.dart';
import '../../core/l10n/strings.dart';
import '../../data/models/filter_state.dart';
import '../../data/models/task.dart';
import '../../providers/category_provider.dart';
import '../../providers/filter_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/task_list_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/home_hero.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);
    final filter = ref.watch(filterProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final statsAsync = ref.watch(statsProvider);
    final searchResults = ref.watch(searchProvider);

    final categoryColors = categoriesAsync.valueOrNull != null
        ? {for (final c in categoriesAsync.valueOrNull!) c.uuid: c.color}
        : <String, int>{};

    return Scaffold(
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          final hasQuery = _showSearch && _searchController.text.trim().isNotEmpty;
          final effectiveTasks = hasQuery
              ? (searchResults.valueOrNull ?? tasks)
              : tasks;
          final filtered = filter.apply(effectiveTasks);
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
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                HomeHero(
                  todayTotal: todayTasks.length,
                  todayCompleted: todayCompleted,
                  streak: streak,
                ),
                _buildSearchBar(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.md, Spacing.sm, Spacing.md, 0),
                  child: Row(
                    children: [
                      Text(
                        _showSearch ? S.searchHasil : S.homeProgressMingguan,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      _FilterAction(filter: filter, ref: ref),
                    ],
                  ),
                ),
                if (filtered.isEmpty)
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
                      )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskFormSheet(context),
        child: const Icon(Icons.add),
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
      onAction: filter.isActive
          ? null
          : () => showTaskFormSheet(context),
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
    if (grouped.containsKey(S.hariIni)) ordered[S.hariIni] = grouped[S.hariIni]!;
    if (grouped.containsKey(S.besok)) ordered[S.besok] = grouped[S.besok]!;
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
            color: filter.isActive
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          label: Text(S.filterTitle),
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

  const _TaskSection({
    required this.label,
    required this.tasks,
    required this.ref,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, 4),
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
          return TweenAnimationBuilder<double>(
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
                onTap: () => showTaskFormSheet(context, taskId: task.uuid),
                onToggle: (_) =>
                    ref.read(taskListProvider.notifier).toggleComplete(task),
                onDismiss: () =>
                    ref.read(taskListProvider.notifier).softDelete(task),
              ),
            ),
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
      return '${S.hariIni} — ${DateFormat('d MMM', 'id').format(today)}';
    }
    if (key == S.besok) {
      return '${S.besok} — ${DateFormat('d MMM', 'id').format(tomorrow)}';
    }
    return key;
  }
}
