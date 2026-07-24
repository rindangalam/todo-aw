import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../providers/category_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/task_list_provider.dart';
import '../widgets/error_state.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchResults = ref.watch(searchProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    final categoryColors = categoriesAsync.valueOrNull != null
        ? {for (final c in categoriesAsync.valueOrNull!) c.uuid: c.color}
        : <String, int>{};

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: S.searchHint,
            border: InputBorder.none,
          ),
          onChanged: (v) => ref.read(searchProvider.notifier).search(v),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).search('');
              },
            ),
        ],
      ),
      body: searchResults.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(detail: e.toString()),
        data: (tasks) {
          if (_searchController.text.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    S.searchKetik,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            );
          }
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    '${S.searchTidakDitemukan} "${_searchController.text}"',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(top: 8),
            children: tasks
                .map((task) => TaskCard(
                      task: task,
                      categoryColor: task.categoryId != null
                          ? Color(categoryColors[task.categoryId] ?? 0xFF9CA3AF)
                          : null,
                      onTap: () =>
                          showTaskFormSheet(context, taskId: task.uuid),
                      onToggle: (_) => ref
                          .read(taskListProvider.notifier)
                          .toggleComplete(task),
                      onDismiss: () =>
                          ref.read(taskListProvider.notifier).softDelete(task),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
