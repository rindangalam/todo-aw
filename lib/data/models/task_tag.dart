class TaskTag {
  final String taskId;
  final String tagId;

  const TaskTag({
    required this.taskId,
    required this.tagId,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'tagId': tagId,
    };
  }

  factory TaskTag.fromMap(Map<String, dynamic> map) {
    return TaskTag(
      taskId: map['taskId'] as String,
      tagId: map['tagId'] as String,
    );
  }
}
