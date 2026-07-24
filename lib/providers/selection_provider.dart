import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionState {
  final bool isActive;
  final Set<String> selectedIds;

  const SelectionState({
    this.isActive = false,
    this.selectedIds = const {},
  });

  SelectionState copyWith({
    bool? isActive,
    Set<String>? selectedIds,
  }) {
    return SelectionState(
      isActive: isActive ?? this.isActive,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

final selectionProvider =
    StateNotifierProvider<SelectionNotifier, SelectionState>((ref) {
  return SelectionNotifier();
});

class SelectionNotifier extends StateNotifier<SelectionState> {
  SelectionNotifier() : super(const SelectionState());

  void enterSelectionMode(String id) {
    state = SelectionState(isActive: true, selectedIds: {id});
  }

  void exitSelectionMode() {
    state = const SelectionState();
  }

  void toggle(String id) {
    final ids = Set<String>.from(state.selectedIds);
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    if (ids.isEmpty) {
      state = const SelectionState();
    } else {
      state = state.copyWith(selectedIds: ids);
    }
  }

  void selectAll(Set<String> ids) {
    state = state.copyWith(isActive: true, selectedIds: ids);
  }

  void clearSelection() {
    if (state.isActive) {
      state = state.copyWith(selectedIds: {});
    }
  }
}
