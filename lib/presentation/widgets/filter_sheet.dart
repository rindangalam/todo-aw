import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/tokens.dart';
import '../../core/l10n/strings.dart';
import '../../data/models/task.dart';
import '../../providers/category_provider.dart';
import '../../providers/filter_provider.dart';
import '../../providers/tag_provider.dart';

class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoryListProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.filterTitle, style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: () {
                  ref.read(filterProvider.notifier).reset();
                },
                child: const Text(S.filterReset),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(S.filterStatus,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildChip(
                context,
                label: S.filterTampilkanSelesai,
                selected: filter.showCompleted,
                onSelected: (_) =>
                    ref.read(filterProvider.notifier).toggleShowCompleted(),
              ),
              _buildChip(
                context,
                label: S.filterTampilkanArsip,
                selected: filter.showArchived,
                onSelected: (_) =>
                    ref.read(filterProvider.notifier).toggleShowArchived(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(S.filterPrioritas,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Priority.values.map((p) {
              final selected = filter.priority == p;
              return _priorityChip(context, p, selected: selected,
                  onSelected: (_) {
                ref.read(filterProvider.notifier).setPriority(p);
              });
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(S.filterKategori,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          categoriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (categories) {
              return Wrap(
                spacing: 8,
                children: [
                  _buildChip(
                    context,
                    label: S.filterSemua,
                    selected: filter.categoryId == null,
                    onSelected: (_) =>
                        ref.read(filterProvider.notifier).setCategory(null),
                  ),
                  ...categories.map((c) {
                    final selected = filter.categoryId == c.uuid;
                    return _buildChip(
                      context,
                      label: c.name,
                      selected: selected,
                      onSelected: (_) =>
                          ref.read(filterProvider.notifier).setCategory(c.uuid),
                    );
                  }),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Label',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ref.watch(tagListProvider).when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (tags) {
                  if (tags.isEmpty) return const SizedBox.shrink();
                  return Wrap(
                    spacing: 8,
                    children: tags.map((t) {
                      final selected = filter.tagIds.contains(t.uuid);
                      return FilterChip(
                        avatar: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(t.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        label:
                            Text(t.name, style: const TextStyle(fontSize: 12)),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) =>
                            ref.read(filterProvider.notifier).toggleTag(t.uuid),
                      );
                    }).toList(),
                  );
                },
              ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(S.filterTerapkan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priorityChip(
    BuildContext context,
    Priority p, {
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    final color = _priorityColor(p);
    return FilterChip(
      avatar: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      label: Text(
        p.name.toUpperCase(),
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? color : null,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      selectedColor: color.withOpacity(0.12),
      side: selected
          ? BorderSide(color: color, width: 1)
          : BorderSide(color: color.withOpacity(0.3), width: 1),
      onSelected: onSelected,
    );
  }

  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.p1:
        return const Color(0xFFEF4444);
      case Priority.p2:
        return const Color(0xFFF59E0B);
      case Priority.p3:
        return const Color(0xFF3B82F6);
      case Priority.p4:
        return const Color(0xFF9CA3AF);
    }
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FilterChip(
      avatar: selected ? const Icon(Icons.check, size: 16) : null,
      label: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      selectedColor: isDark
          ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
          : Theme.of(context).colorScheme.primary.withOpacity(0.15),
      side: selected
          ? BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            )
          : null,
      onSelected: onSelected,
    );
  }
}

Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(RadiusTokens.lg)),
    ),
    builder: (_) => const FilterSheet(),
  );
}
