import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/tokens.dart';
import '../../data/models/note.dart';
import '../../data/models/task.dart';
import '../../providers/note_provider.dart';
import '../../providers/task_list_provider.dart';
import '../widgets/error_state.dart';
import '../widgets/note_card.dart';
import '../widgets/task_card.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arsip'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tugas'),
            Tab(text: 'Catatan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _taskTab(theme),
          _noteTab(theme),
        ],
      ),
    );
  }

  Widget _taskTab(ThemeData theme) {
    final tasksAsync = ref.watch(archivedTaskListProvider);
    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(
        detail: e.toString(),
        onRetry: () => ref.refresh(archivedTaskListProvider),
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return _emptyState(
              theme, Icons.archive_outlined, 'Tidak ada tugas diarsip');
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(archivedTaskListProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md, vertical: Spacing.sm),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: TaskCard(
                  task: task,
                  onTap: () => _unarchiveTask(task),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _noteTab(ThemeData theme) {
    final notesAsync = ref.watch(archivedNoteListProvider);
    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(
        detail: e.toString(),
        onRetry: () => ref.refresh(archivedNoteListProvider),
      ),
      data: (notes) {
        if (notes.isEmpty) {
          return _emptyState(
              theme, Icons.archive_outlined, 'Tidak ada catatan diarsip');
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(archivedNoteListProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md, vertical: Spacing.sm),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _ArchivedNoteCard(
                    note: note, onRestore: () => _unarchiveNote(note)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _emptyState(ThemeData theme, IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: Spacing.md),
          Text(message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              )),
        ],
      ),
    );
  }

  Future<void> _unarchiveTask(Task task) async {
    await ref.read(taskListProvider.notifier).unarchive(task);
    ref.invalidate(archivedTaskListProvider);
  }

  Future<void> _unarchiveNote(Note note) async {
    await ref
        .read(noteListProvider.notifier)
        .update(note.copyWith(isArchived: false));
    ref.invalidate(archivedNoteListProvider);
  }
}

class _ArchivedNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onRestore;

  const _ArchivedNoteCard({required this.note, required this.onRestore});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(note.uuid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: ColorTokens.success,
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Kembalikan',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            SizedBox(width: 8),
            Icon(Icons.restore, color: Colors.white, size: 20),
          ],
        ),
      ),
      onDismissed: (_) => onRestore(),
      child: NoteCard(note: note),
    );
  }
}
