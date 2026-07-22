import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../data/models/recurrence.dart';

class RecurringPicker extends StatelessWidget {
  final RecurrenceRule? initial;
  final ValueChanged<RecurrenceRule> onChanged;
  final VoidCallback onRemove;

  const RecurringPicker({
    super.key,
    this.initial,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.taskUlangi, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(context, S.repeatTidakPernah, null),
              _chip(context, S.repeatSetiapHari, RecurrenceFrequency.daily),
              _chip(context, S.repeatHariKerja, RecurrenceFrequency.weekday),
              _chip(context, S.repeatSetiapMinggu, RecurrenceFrequency.weekly),
              _chip(context, S.repeatSetiapBulan, RecurrenceFrequency.monthly),
              _chip(context, S.repeatSetiapTahun, RecurrenceFrequency.yearly),
            ],
          ),
          if (initial != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                onRemove();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.remove_circle_outline),
              label: Text(S.repeatHapus),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, RecurrenceFrequency? freq) {
    final selected = freq != null && initial?.frequency == freq;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        if (freq == null) {
          onRemove();
        } else {
          final rule = RecurrenceRule(frequency: freq);
          onChanged(rule);
        }
        Navigator.pop(context);
      },
    );
  }
}

Future<RecurrenceRule?> showRecurringPicker(
  BuildContext context, {
  RecurrenceRule? initial,
}) async {
  RecurrenceRule? result = initial;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return RecurringPicker(
        initial: initial,
        onChanged: (rule) => result = rule,
        onRemove: () => result = null,
      );
    },
  );
  return result;
}
