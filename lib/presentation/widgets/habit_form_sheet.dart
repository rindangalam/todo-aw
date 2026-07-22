import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/tokens.dart';
import '../../core/l10n/strings.dart';
import '../../data/models/habit.dart';
import '../../providers/habit_provider.dart';

Future<void> showHabitFormSheet(BuildContext context, {String? habitId}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.lg)),
    ),
    builder: (_) => ProviderScope(
      overrides: const [],
      child: HabitFormSheet(habitId: habitId),
    ),
  );
}

class HabitFormSheet extends ConsumerStatefulWidget {
  final String? habitId;

  const HabitFormSheet({super.key, this.habitId});

  @override
  ConsumerState<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends ConsumerState<HabitFormSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _loading = true;
  int _selectedColor = 0xFF5865F2;
  HabitFrequency _frequency = HabitFrequency.daily;
  int _targetCount = 1;

  static const _colors = [
    0xFF5865F2,
    0xFF10B981,
    0xFFF59E0B,
    0xFFEF4444,
    0xFF8B5CF6,
    0xFFEC4899,
  ];

  @override
  void initState() {
    super.initState();
    _loadHabit();
  }

  Future<void> _loadHabit() async {
    if (widget.habitId != null) {
      final habit =
          await ref.read(habitRepositoryProvider).getById(widget.habitId!);
      if (habit != null && mounted) {
        _nameController.text = habit.name;
        _descController.text = habit.description ?? '';
        _selectedColor = habit.color;
        _frequency = habit.frequency;
        _targetCount = habit.targetCount;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    if (_loading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: S.habitNamaHint,
              labelText: S.habitNama,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: S.notesContentHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(S.habitFrekuensi,
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              DropdownButton<HabitFrequency>(
                value: _frequency,
                items: const [
                  DropdownMenuItem(
                      value: HabitFrequency.daily, child: Text('Harian')),
                  DropdownMenuItem(
                      value: HabitFrequency.weekly, child: Text('Mingguan')),
                  DropdownMenuItem(
                      value: HabitFrequency.monthly, child: Text('Bulanan')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _frequency = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(S.habitTarget,
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              _CounterButton(
                value: _targetCount,
                onChanged: (v) => setState(() => _targetCount = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _colors.map((c) => GestureDetector(
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
                              color: theme.colorScheme.primary, width: 2.5)
                          : null,
                    ),
                  ),
                )).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(widget.habitId != null ? S.simpan : S.tambah),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final desc = _descController.text.trim();
    if (widget.habitId != null) {
      final existing =
          await ref.read(habitRepositoryProvider).getById(widget.habitId!);
      if (existing != null) {
        await ref.read(habitListProvider.notifier).update(
              existing.copyWith(
                name: name,
                description: desc.isEmpty ? null : desc,
                color: _selectedColor,
                frequency: _frequency,
                targetCount: _targetCount,
              ),
            );
      }
    } else {
      await ref.read(habitListProvider.notifier).create(
            name: name,
            description: desc.isEmpty ? null : desc,
            color: _selectedColor,
            frequency: _frequency,
            targetCount: _targetCount,
          );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _CounterButton extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _CounterButton({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
        ),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w600)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }
}
