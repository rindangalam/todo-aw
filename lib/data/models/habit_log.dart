class HabitLog {
  final String uuid;
  final String habitId;
  final DateTime date;
  final bool isCompleted;
  final String? note;
  final DateTime createdAt;

  const HabitLog({
    required this.uuid,
    required this.habitId,
    required this.date,
    this.isCompleted = true,
    this.note,
    required this.createdAt,
  });

  HabitLog copyWith({
    String? uuid,
    String? habitId,
    DateTime? date,
    bool? isCompleted,
    String? note,
    DateTime? createdAt,
  }) {
    return HabitLog(
      uuid: uuid ?? this.uuid,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      uuid: map['uuid'] as String,
      habitId: map['habitId'] as String,
      date: DateTime.parse(map['date'] as String),
      isCompleted: (map['isCompleted'] as int?) == 1,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
