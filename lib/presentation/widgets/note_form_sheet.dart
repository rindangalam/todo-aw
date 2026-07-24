import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/tokens.dart';
import '../../core/l10n/strings.dart';
import '../../providers/note_provider.dart';

Future<void> showNoteFormSheet(BuildContext context, {String? noteId}) {
  return showDialog(
    context: context,
    useSafeArea: false,
    barrierDismissible: false,
    builder: (_) => NoteFormSheet(noteId: noteId),
  );
}

class NoteFormSheet extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteFormSheet({super.key, this.noteId});

  @override
  ConsumerState<NoteFormSheet> createState() => _NoteFormSheetState();
}

class _NoteFormSheetState extends ConsumerState<NoteFormSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _loading = true;
  int _selectedColor = 0xFFFDE68A;
  bool _isPinned = false;

  static const _colors = [
    0xFFFDE68A,
    0xFFA7F3D0,
    0xFFBFDBFE,
    0xFFC7D2FE,
    0xFFFECACA,
    0xFFE2E8F0,
  ];

  bool get _isEditing => widget.noteId != null;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    if (widget.noteId != null) {
      final note =
          await ref.read(noteRepositoryProvider).getById(widget.noteId!);
      if (note != null && mounted) {
        _titleController.text = note.title;
        _contentController.text = note.content ?? '';
        _selectedColor = note.color;
        _isPinned = note.isPinned;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    if (_loading) {
      return const Material(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Material(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    _isEditing ? S.notesEdit : S.notesBaru,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: S.notesTitleHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.sm),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: S.notesContentHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.sm),
                    ),
                    filled: true,
                    fillColor:
                        theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ..._colors.map((c) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = c),
                        child: Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,
                            border: _selectedColor == c
                                ? Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2.5)
                                : null,
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 18,
                    color: _isPinned
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    S.notesSematkanDiForm,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isPinned,
                    onChanged: (v) => setState(() => _isPinned = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(
                    _isEditing ? S.simpan : S.tambah,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final content = _contentController.text.trim();
    if (_isEditing) {
      final existing =
          await ref.read(noteRepositoryProvider).getById(widget.noteId!);
      if (existing != null) {
        await ref.read(noteListProvider.notifier).update(
              existing.copyWith(
                title: title,
                content: content.isEmpty ? null : content,
                color: _selectedColor,
                isPinned: _isPinned,
              ),
            );
      }
    } else {
      await ref.read(noteListProvider.notifier).create(
            title: title,
            content: content.isEmpty ? null : content,
            color: _selectedColor,
            isPinned: _isPinned,
          );
    }
    if (mounted) Navigator.of(context).pop();
  }
}
