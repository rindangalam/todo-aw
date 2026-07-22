import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../data/models/task.dart';

class PrioritySelector extends StatelessWidget {
  final Priority selected;
  final ValueChanged<Priority> onChanged;

  const PrioritySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  Color _color(Priority p) {
    switch (p) {
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

  String _label(Priority p) {
    switch (p) {
      case Priority.p1:
        return S.prioritasP1;
      case Priority.p2:
        return S.prioritasP2;
      case Priority.p3:
        return S.prioritasP3;
      case Priority.p4:
        return S.prioritasP4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Priority.values.map((p) {
        final isSelected = p == selected;
        final color = _color(p);
        final label = _label(p);
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: isSelected,
            selectedColor: color,
            backgroundColor: color.withOpacity(0.1),
            onSelected: (_) => onChanged(p),
            visualDensity: VisualDensity.compact,
          ),
        );
      }).toList(),
    );
  }
}
