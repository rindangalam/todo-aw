import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../data/models/task.dart';
import '../../providers/category_provider.dart';
import '../../providers/task_list_provider.dart';
import '../widgets/error_state.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

const _idnDayShort = [
  'Sen',
  'Sel',
  'Rab',
  'Kam',
  'Jum',
  'Sab',
  'Min',
];

const _idnDayFull = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const _idnMonths = [
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

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = now;
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _currentMonth = DateTime(now.year, now.month);
      _selectedDate = now;
    });
  }

  List<DateTime> _daysInMonth() {
    final first = _currentMonth;
    final last = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final days = <DateTime>[];
    for (int d = 1; d <= last.day; d++) {
      days.add(DateTime(first.year, first.month, d));
    }
    return days;
  }

  Set<DateTime> _dateSet(List<Task> tasks) {
    return tasks
        .where((t) => t.dueDate != null && !t.isArchived && t.deletedAt == null)
        .map((t) => DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day))
        .toSet();
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isSelected(DateTime d) {
    return d.year == _selectedDate.year &&
        d.month == _selectedDate.month &&
        d.day == _selectedDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(taskListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    final categoryColors = categoriesAsync.valueOrNull != null
        ? {for (final c in categoriesAsync.valueOrNull!) c.uuid: c.color}
        : <String, int>{};

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.08),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(
            detail: e.toString(),
            onRetry: () => ref.read(taskListProvider.notifier).load(),
          ),
          data: (tasks) {
            final taskDates = _dateSet(tasks);
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    _buildHeader(theme),
                    _buildDayHeaders(theme),
                    _buildMonthGrid(theme, taskDates),
                    const SizedBox(height: 8),
                    _buildAgenda(theme, tasks, categoryColors),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _prevMonth,
          ),
          Expanded(
            child: Text(
              '${_idnMonths[_currentMonth.month - 1]} ${_currentMonth.year}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _goToToday,
            icon: const Icon(Icons.today, size: 16),
            label: const Text(
              S.kalenderHariIni,
              style: TextStyle(fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeaders(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: _idnDayShort
            .map((h) => Expanded(
                  child: Center(
                    child: Text(
                      h,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMonthGrid(ThemeData theme, Set<DateTime> taskDates) {
    final days = _daysInMonth();
    final firstWeekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday - 1;
    final cells = <Widget>[];

    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (final day in days) {
      final hasTask = taskDates.contains(day);
      final isToday = _isToday(day);
      final isSel = _isSelected(day);

      cells.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(2),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSel
                  ? theme.colorScheme.primary
                  : isToday
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : null,
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isSel
                  ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: isSel ? 6 : 4),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontWeight:
                        isSel || isToday ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 13,
                    color: isSel
                        ? Colors.white
                        : isToday
                            ? theme.colorScheme.primary
                            : null,
                  ),
                ),
                if (hasTask)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: isSel ? Colors.white : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.1,
        children: cells,
      ),
    );
  }

  Widget _buildAgenda(
      ThemeData theme, List<Task> allTasks, Map<String, int> categoryColors) {
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final dayTasks = allTasks.where((t) {
      if (t.dueDate == null) return false;
      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return d == selected;
    }).toList();

    final isToday = _isToday(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Text(
                '${_idnDayFull[_selectedDate.weekday - 1]}, ${_selectedDate.day} ${_idnMonths[_selectedDate.month - 1]} ${_selectedDate.year}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isToday)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    S.kalenderHariIni,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (dayTasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 40,
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.kalenderTidakAdaTugas,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${dayTasks.length} ${S.kalenderTugasSelesai}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${dayTasks.where((t) => t.isCompleted).length}/${dayTasks.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: dayTasks
                      .map((task) => TaskCard(
                            task: task,
                            categoryColor: task.categoryId != null
                                ? Color(categoryColors[task.categoryId] ??
                                    0xFF9CA3AF)
                                : null,
                            onTap: () =>
                                showTaskFormSheet(context, taskId: task.uuid),
                            onToggle: (_) => ref
                                .read(taskListProvider.notifier)
                                .toggleComplete(task),
                            onDismiss: () => ref
                                .read(taskListProvider.notifier)
                                .softDelete(task),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
