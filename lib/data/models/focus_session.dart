class FocusSession {
  final String uuid;
  final String? taskId;
  final int durationMinutes;
  final bool isCompleted;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;

  const FocusSession({
    required this.uuid,
    this.taskId,
    this.durationMinutes = 25,
    this.isCompleted = false,
    this.startedAt,
    this.endedAt,
    required this.createdAt,
  });

  FocusSession copyWith({
    String? uuid,
    String? taskId,
    int? durationMinutes,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
  }) {
    return FocusSession(
      uuid: uuid ?? this.uuid,
      taskId: taskId ?? this.taskId,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'taskId': taskId,
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted ? 1 : 0,
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      uuid: map['uuid'] as String,
      taskId: map['taskId'] as String?,
      durationMinutes: map['durationMinutes'] as int? ?? 25,
      isCompleted: (map['isCompleted'] as int?) == 1,
      startedAt: map['startedAt'] != null
          ? DateTime.parse(map['startedAt'] as String)
          : null,
      endedAt: map['endedAt'] != null
          ? DateTime.parse(map['endedAt'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
