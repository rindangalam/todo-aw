import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../core/l10n/strings.dart';
import '../../data/models/note.dart';
import '../../providers/note_provider.dart';
import '../../services/tour_service.dart';
import '../widgets/error_state.dart';
import '../widgets/note_card.dart';
import '../widgets/note_form_sheet.dart';
import '../widgets/tour_card.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();
  final _notesFabKey = GlobalKey();
  final _noteCardKey = GlobalKey();

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
    final seen = await TourService.isCoachmarkNotesSeen();
    if (seen || !mounted) return;

    final targets = [
      TargetFocus(
        identify: 'note_card',
        keyTarget: _noteCardKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => TourCard(
              title: 'Kelola Catatan',
              body:
                  'Tap catatan buat ngedit. Tekan agak lama buat sematkan atau hapus.',
              onNext: controller.next,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'notes_fab',
        keyTarget: _notesFabKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => TourCard(
              title: 'Tambah Catatan',
              body:
                  'Tap + buat catatan baru — kasih judul, isi, warna, '
                  'dan sematkan kalau penting.',
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
        if (target.identify == 'notes_fab') {
          TourService.markCoachmarkNotesSeen();
        }
      },
      onClickOverlay: (target) {
        if (target.identify == 'notes_fab') {
          TourService.markCoachmarkNotesSeen();
        }
      },
      onFinish: () => TourService.markCoachmarkNotesSeen(),
      onSkip: () {
        TourService.markCoachmarkNotesSeen();
        return true;
      },
    ).show();
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
                onChanged: (q) => ref.read(noteListProvider.notifier).search(q),
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
        error: (e, _) => ErrorState(
          detail: e.toString(),
          onRetry: () => ref.read(noteListProvider.notifier).load(),
        ),
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

          final crossAxisCount =
              MediaQuery.of(context).size.width > 600 ? 3 : 2;
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
                          color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text(
                        S.notesDisematkan,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
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
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return Container(
                          key: _noteCardKey,
                          child: _buildNoteCard(unpinned[i], theme));
                    }
                    return _buildNoteCard(unpinned[i], theme);
                  },
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: _notesFabKey,
        onPressed: () => showNoteFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(Note note, ThemeData theme) {
    return NoteCard(
      note: note,
      onTap: () => showNoteFormSheet(context, noteId: note.uuid),
      onTogglePin: () => ref.read(noteListProvider.notifier).togglePin(note),
      onLongPress: () => _showNoteMenu(context, theme, note),
    );
  }

  void _showNoteMenu(BuildContext context, ThemeData theme, Note note) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(note.isPinned ? S.notesLepasPin : S.notesPin),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(noteListProvider.notifier).togglePin(note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(S.notesHapus,
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(note);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.notesKonfirmasiHapus),
        content: const Text(S.notesKonfirmasiHapusDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(S.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              S.hapus,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(noteListProvider.notifier).delete(note);
    }
  }
}
