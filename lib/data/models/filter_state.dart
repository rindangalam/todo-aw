import 'task.dart';

class FilterState {
  final bool showCompleted;
  final Priority? priority;
  final String? categoryId;
  final bool showArchived;

  const FilterState({
    this.showCompleted = true,
    this.priority,
    this.categoryId,
    this.showArchived = false,
  });

  bool get isActive =>
      !showCompleted || priority != null || categoryId != null || showArchived;

  FilterState copyWith({
    bool? showCompleted,
    Priority? priority,
    String? categoryId,
    bool? showArchived,
  }) {
    return FilterState(
      showCompleted: showCompleted ?? this.showCompleted,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      showArchived: showArchived ?? this.showArchived,
    );
  }

  List<Task> apply(List<Task> tasks) {
    return tasks.where((t) {
      if (!showCompleted && t.isCompleted) return false;
      if (priority != null && t.priority != priority) return false;
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (!showArchived && t.isArchived) return false;
      return true;
    }).toList();
  }
}
