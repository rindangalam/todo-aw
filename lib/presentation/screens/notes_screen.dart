import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/note_form_sheet.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notesAsync = ref.watch(noteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: S.searchHint,
                  border: InputBorder.none,
                ),
                onChanged: (q) =>
                    ref.read(noteListProvider.notifier).search(q),
              )
            : const Text(S.notesTitle),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  ref.read(noteListProvider.notifier).load();
                }
              });
            },
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${S.error}: $e')),
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showSearch ? S.searchTidakDitemukan : S.notesKosong,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (!_showSearch) ...[
                      const SizedBox(height: 8),
                      Text(
                        S.notesBuatPertama,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          final pinned = notes.where((n) => n.isPinned).toList();
          final unpinned = notes.where((n) => !n.isPinned).toList();

          final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
            children: [
              if (pinned.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                  child: Row(
                    children: [
                      Icon(Icons.push_pin,
                          size: 14,
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text(
                        S.notesDisematkan,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: pinned.length,
                  itemBuilder: (_, i) => _buildNoteCard(pinned[i], theme),
                ),
              ],
              if (unpinned.isNotEmpty) ...[
                if (pinned.isNotEmpty) const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: unpinned.length,
                  itemBuilder: (_, i) =>
                      _buildNoteCard(unpinned[i], theme),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNoteFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(note, ThemeData theme) {
    return NoteCard(
      note: note,
      onTap: () => showNoteFormSheet(context, noteId: note.uuid),
      onTogglePin: () =>
          ref.read(noteListProvider.notifier).togglePin(note),
    );
  }
}
