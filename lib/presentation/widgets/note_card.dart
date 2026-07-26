import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onTogglePin;
  final VoidCallback? onLongPress;
  final VoidCallback? onDismiss;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onTogglePin,
    this.onLongPress,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = Color(note.color).withOpacity(isDark ? 0.25 : 0.65);

    final card = Card(
      elevation: 1,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    IconButton(
                      icon: const Icon(Icons.push_pin, size: 16),
                      onPressed: onTogglePin,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
              if (note.content != null && note.content!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  note.content!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                DateFormat('d MMM yyyy').format(note.updatedAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onDismiss != null) {
      return Dismissible(
        key: ValueKey('note-${note.uuid}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.archive, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Arsip',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          onDismiss?.call();
          return false;
        },
        child: card,
      );
    }

    return card;
  }
}
