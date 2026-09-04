import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/design/tokens.dart';
import '../../core/l10n/strings.dart';
import '../../data/models/recurrence.dart';
import '../../data/models/task.dart';
import '../../providers/category_provider.dart';
import '../../providers/tag_provider.dart';
import '../../providers/task_list_provider.dart';
import '../widgets/priority_selector.dart';
import '../widgets/recurring_picker.dart';

Future<T?> showTaskFormSheet<T>(BuildContext context, {String? taskId}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(RadiusTokens.lg)),
    ),
    builder: (_) => TaskFormSheet(taskId: taskId),
  );
}

class TaskFormSheet extends ConsumerStatefulWidget {
  final String? taskId;

  const TaskFormSheet({super.key, this.taskId});

  @override
  ConsumerState<TaskFormSheet> createState() => TaskFormSheetState();
}

class TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subtaskController = TextEditingController();
  var _priority = Priority.p3;
  String? _categoryId;
  DateTime? _dueDate;
  RecurrenceRule? _recurrence;
  int _reminderMinutes = 30;
  bool _isLoading = false;
  List<Task> _subtasks = [];
  String? _parentTaskId;
  List<String> _selectedTagIds = [];

  static const List<int> _reminderOptions = [
    5, 10, 15, 20, 30, 45, 60, 120, 240, 1440,
  ];

  String _formatReminder(int minutes) {
    if (minutes < 60) return '$minutes menit sebelumnya';
    if (minutes == 60) return '1 jam sebelumnya';
    if (minutes < 1440) return '${minutes ~/ 60} jam sebelumnya';
    return '${minutes ~/ 1440} hari sebelumnya';
  }

  Future<void> _showCustomReminderDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Pengingat'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Menit',
            suffixText: 'menit sebelum deadline',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                Navigator.pop(context, val);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      setState(() => _reminderMinutes = result);
    }
  }

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadTask();
      _loadSubtasks();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    final repo = ref.read(taskRepositoryProvider);
    final task = await repo.getById(widget.taskId!);
    if (task != null && mounted) {
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      setState(() {
        _priority = task.priority;
        _categoryId = task.categoryId;
        _dueDate = task.dueDate;
        _recurrence = RecurrenceRule.fromRrule(task.recurringRule);
        _parentTaskId = task.parentId;
        _reminderMinutes = task.reminderMinutes ?? 30;
      });
      final tagIds =
          await ref.read(tagRepositoryProvider).getTaskTags(widget.taskId!);
      if (mounted) setState(() => _selectedTagIds = tagIds);
    }
  }

  Future<void> _loadSubtasks() async {
    final repo = ref.read(taskRepositoryProvider);
    final allTasks = await repo.getAll();
    final sub = allTasks.where((t) => t.parentId == widget.taskId).toList();
    if (mounted) setState(() => _subtasks = sub);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tagRepo = ref.read(tagRepositoryProvider);
      final notifier = ref.read(taskListProvider.notifier);
      if (_isEditing) {
        final repo = ref.read(taskRepositoryProvider);
        final existing = await repo.getById(widget.taskId!);
        if (existing != null) {
          await notifier.updateTask(existing.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            priority: _priority,
            categoryId: _categoryId,
            dueDate: _dueDate,
            isRecurring: _recurrence != null,
            recurringRule: _recurrence?.toRrule(),
            reminderMinutes: _reminderMinutes,
          ));
          await tagRepo.setTaskTags(widget.taskId!, _selectedTagIds);
        }
      } else {
        final task = await notifier.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          priority: _priority,
          categoryId: _categoryId,
          dueDate: _dueDate,
          isRecurring: _recurrence != null,
          recurringRule: _recurrence?.toRrule(),
          reminderMinutes: _reminderMinutes,
        );
        await tagRepo.setTaskTags(task.uuid, _selectedTagIds);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null && mounted) {
      final currentTime = _dueDate ?? now;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentTime),
      );
      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      } else {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            currentTime.hour,
            currentTime.minute,
          );
        });
      }
    }
  }

  Future<void> _addSubtask() async {
    if (_parentTaskId != null) return;
    final title = _subtaskController.text.trim();
    if (title.isEmpty) return;

    final repo = ref.read(taskRepositoryProvider);
    await repo.create(
      title: title,
      priority: _priority,
      parentId: widget.taskId,
    );
    _subtaskController.clear();
    await _loadSubtasks();
  }

  Future<void> _toggleSubtask(Task subtask) async {
    final notifier = ref.read(taskListProvider.notifier);
    await notifier.toggleComplete(subtask);
    await _loadSubtasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoryListProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            children: [
              _dragHandle(context),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                        Spacing.lg, 0, Spacing.lg, Spacing.xl),
                    children: [
                      _header(theme),
                      const SizedBox(height: Spacing.lg),
                      TextFormField(
                        controller: _titleController,
                        autofocus: !_isEditing,
                        maxLength: AppConstants.taskTitleMaxLength,
                        decoration: InputDecoration(
                          labelText: S.taskJudul,
                          hintText: S.taskJudulHint,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(RadiusTokens.sm),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? S.taskJudulRequired
                            : null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: Spacing.md),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: S.taskDeskripsi,
                          hintText: S.taskDeskripsiHint,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(RadiusTokens.sm),
                          ),
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: Spacing.lg),
                      Text(S.taskPrioritas,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: Spacing.xs),
                      PrioritySelector(
                        selected: _priority,
                        onChanged: (p) => setState(() => _priority = p),
                      ),
                      const SizedBox(height: Spacing.lg),
                      _sectionDivider(),
                      const SizedBox(height: Spacing.md),
                      _fieldRow(
                        icon: Icons.category,
                        label: S.taskKategori,
                        child: categoriesAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) =>
                              const Text('Error loading categories'),
                          data: (categories) {
                            return DropdownButtonFormField<String?>(
                              value: _categoryId,
                              decoration: InputDecoration(
                                hintText: S.taskTidakAdaKategori,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(RadiusTokens.sm),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text(S.taskTidakAdaKategori),
                                ),
                                ...categories.map((c) => DropdownMenuItem(
                                      value: c.uuid,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Color(c.color),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(c.name),
                                        ],
                                      ),
                                    )),
                              ],
                              onChanged: (v) => setState(() => _categoryId = v),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      _fieldRow(
                        icon: Icons.label_outline,
                        label: 'Label',
                        child: Consumer(builder: (context, ref, _) {
                          final tagsAsync = ref.watch(tagListProvider);
                          return tagsAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (tags) {
                              if (tags.isEmpty) {
                                return const Text('Tidak ada label',
                                    style: TextStyle(fontSize: 14));
                              }
                              return Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: tags.map((tag) {
                                  final selected =
                                      _selectedTagIds.contains(tag.uuid);
                                  return FilterChip(
                                    avatar: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Color(tag.color),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    label: Text(tag.name,
                                        style: const TextStyle(fontSize: 12)),
                                    selected: selected,
                                    showCheckmark: false,
                                    onSelected: (v) {
                                      setState(() {
                                        if (v) {
                                          _selectedTagIds.add(tag.uuid);
                                        } else {
                                          _selectedTagIds.remove(tag.uuid);
                                        }
                                      });
                                    },
                                    visualDensity: VisualDensity.compact,
                                  );
                                }).toList(),
                              );
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: Spacing.md),
                      _fieldRow(
                        icon: Icons.repeat,
                        label: S.taskUlangi,
                        child: InkWell(
                          onTap: () async {
                            final result = await showRecurringPicker(
                              context,
                              initial: _recurrence,
                            );
                            if (result != null || _recurrence != null) {
                              setState(() => _recurrence = result);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(RadiusTokens.sm),
                              ),
                              suffixIcon: _recurrence != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () =>
                                          setState(() => _recurrence = null),
                                    )
                                  : const Icon(Icons.repeat),
                            ),
                            child: Text(
                              _recurrence?.displayText() ?? S.taskTidakBerulang,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      _fieldRow(
                        icon: Icons.calendar_today,
                        label: S.taskDeadline,
                        child: InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(RadiusTokens.sm),
                              ),
                              suffixIcon: _dueDate != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () =>
                                          setState(() => _dueDate = null),
                                    )
                                  : const Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _dueDate != null
                                  ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year} ${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}'
                                  : S.taskPilihTanggal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      _fieldRow(
                        icon: Icons.notifications_outlined,
                        label: 'Pengingat',
                        child: Column(
                          children: [
                            DropdownButtonFormField<int>(
                              value: _reminderOptions.contains(_reminderMinutes) ? _reminderMinutes : -1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(RadiusTokens.sm),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              items: [
                                const DropdownMenuItem(
                                    value: null,
                                    child: Text('Pilih...')),
                                ..._reminderOptions.map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(_formatReminder(m)),
                                    )),
                                const DropdownMenuItem(
                                    value: -1,
                                    child: Text('Custom...')),
                              ],
                              onChanged: (v) {
                                if (v == -1) {
                                  _showCustomReminderDialog();
                                } else if (v != null) {
                                  setState(() => _reminderMinutes = v);
                                }
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Saat ini: ${_formatReminder(_reminderMinutes)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      if (_isEditing) ...[
                        const SizedBox(height: Spacing.lg),
                        _sectionDivider(),
                        const SizedBox(height: Spacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final repo = ref.read(taskRepositoryProvider);
                              final task = await repo.getById(widget.taskId!);
                              if (task != null) {
                                await ref
                                    .read(taskListProvider.notifier)
                                    .archive(task);
                                if (mounted) Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.archive),
                            label: const Text(S.taskArsipkan),
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final repo = ref.read(taskRepositoryProvider);
                              final task = await repo.getById(widget.taskId!);
                              if (task != null) {
                                await ref
                                    .read(taskListProvider.notifier)
                                    .saveAsTemplate(task);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            S.taskDisimpanSebagaiTemplate)),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.bookmark_border),
                            label: const Text(S.taskSimpanSebagaiTemplate),
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        Text(S.taskSubtask,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: Spacing.xs),
                        ..._subtasks.map((sub) => ListTile(
                              dense: true,
                              leading: Checkbox(
                                value: sub.isCompleted,
                                onChanged: (_) => _toggleSubtask(sub),
                                shape: const CircleBorder(),
                              ),
                              title: Text(
                                sub.title,
                                style: TextStyle(
                                  decoration: sub.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            )),
                        if (_parentTaskId != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Hanya bisa 2 level subtask',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _subtaskController,
                                  decoration: InputDecoration(
                                    hintText: S.taskTambahSubtask,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          RadiusTokens.sm),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                  ),
                                  onSubmitted: (_) => _addSubtask(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _addSubtask,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                      ],
                      const SizedBox(height: Spacing.xl),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _save,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  S.simpan,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dragHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm, bottom: Spacing.xs),
      child: Center(
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _header(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          _isEditing ? S.taskEdit : S.taskBaru,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _sectionDivider() {
    return Divider(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
    );
  }

  Widget _fieldRow({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: Spacing.xs),
        child,
      ],
    );
  }
}
