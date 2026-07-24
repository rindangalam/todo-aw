import 'task.dart';

class FilterState {
  final bool showCompleted;
  final Priority? priority;
  final String? categoryId;
  final bool showArchived;
  final Set<String> tagIds;

  const FilterState({
    this.showCompleted = true,
    this.priority,
    this.categoryId,
    this.showArchived = false,
    this.tagIds = const {},
  });

  bool get isActive =>
      !showCompleted ||
      priority != null ||
      categoryId != null ||
      showArchived ||
      tagIds.isNotEmpty;

  FilterState copyWith({
    bool? showCompleted,
    Priority? priority,
    String? categoryId,
    bool? showArchived,
    Set<String>? tagIds,
  }) {
    return FilterState(
      showCompleted: showCompleted ?? this.showCompleted,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      showArchived: showArchived ?? this.showArchived,
      tagIds: tagIds ?? this.tagIds,
    );
  }

  List<Task> apply(List<Task> tasks, {Map<String, Set<String>>? taskTagMap}) {
    return tasks.where((t) {
      if (!showCompleted && t.isCompleted) return false;
      if (priority != null && t.priority != priority) return false;
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (!showArchived && t.isArchived) return false;
      if (tagIds.isNotEmpty && taskTagMap != null) {
        final taskTags = taskTagMap[t.uuid] ?? {};
        if (tagIds.intersection(taskTags).isEmpty) return false;
      }
      return true;
    }).toList();
  }
}
