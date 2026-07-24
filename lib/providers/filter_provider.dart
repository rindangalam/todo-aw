import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/filter_state.dart';

final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void toggleShowCompleted() {
    state = state.copyWith(showCompleted: !state.showCompleted);
  }

  void setPriority(dynamic priority) {
    if (state.priority == priority) {
      state = FilterState(
        showCompleted: state.showCompleted,
        categoryId: state.categoryId,
        showArchived: state.showArchived,
      );
    } else {
      state = state.copyWith(priority: priority);
    }
  }

  void setCategory(String? categoryId) {
    if (state.categoryId == categoryId) {
      state = FilterState(
        showCompleted: state.showCompleted,
        priority: state.priority,
        showArchived: state.showArchived,
      );
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
  }

  void toggleShowArchived() {
    state = state.copyWith(showArchived: !state.showArchived);
  }

  void reset() {
    state = const FilterState();
  }

  void toggleTag(String tagId) {
    final ids = Set<String>.from(state.tagIds);
    if (ids.contains(tagId)) {
      ids.remove(tagId);
    } else {
      ids.add(tagId);
    }
    state = state.copyWith(tagIds: ids);
  }
}
