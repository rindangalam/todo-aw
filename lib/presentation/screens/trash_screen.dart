import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n/strings.dart';
import '../../data/models/task.dart';
import '../../providers/task_list_provider.dart';
import '../widgets/error_state.dart';

final trashListProvider = FutureProvider<List<Task>>((ref) {
  return ref.read(taskRepositoryProvider).getTrashed();
});

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashAsync = ref.watch(trashListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.trashTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _emptyAll(context, ref),
            tooltip: S.trashHapusSemua,
          ),
        ],
      ),
      body: trashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          detail: e.toString(),
          onRetry: () => ref.refresh(trashListProvider),
        ),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    S.trashKosong,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.trashAutoDelete,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  S.trashAutoDelete,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final daysLeft = task.deletedAt != null
                        ? AppConstants.trashAutoPurgeDays -
                            DateTime.now().difference(task.deletedAt!).inDays
                        : AppConstants.trashAutoPurgeDays;
                    return Card(
                      child: ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          daysLeft > 0
                              ? '${_timeAgo(task.deletedAt!)} · $daysLeft ${S.trashHariLagii}'
                              : S.trashAkanDihapus,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: daysLeft < 5
                                ? Colors.red
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore),
                              tooltip: S.trashKembalikan,
                              onPressed: () async {
                                await ref
                                    .read(taskRepositoryProvider)
                                    .restore(task.uuid);
                                ref.invalidate(trashListProvider);
                                ref.invalidate(taskListProvider);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever),
                              tooltip: S.trashHapusPermanen,
                              onPressed: () =>
                                  _permanentDelete(context, ref, task),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _permanentDelete(BuildContext context, WidgetRef ref, Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.trashKonfirmasiHapus),
        content: const Text(S.trashKonfirmasiHapusDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(S.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(S.hapus),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(taskRepositoryProvider).delete(task.uuid);
      ref.invalidate(trashListProvider);
      ref.invalidate(taskListProvider);
    }
  }

  void _emptyAll(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.trashKonfirmasiKosongkan),
        content: const Text(S.trashKonfirmasiKosongkanDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(S.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(S.trashKosongkan),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(taskRepositoryProvider).emptyTrash();
      ref.invalidate(trashListProvider);
      ref.invalidate(taskListProvider);
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    return '${diff.inDays}h yang lalu';
  }
}
