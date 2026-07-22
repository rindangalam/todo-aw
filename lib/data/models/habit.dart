enum HabitFrequency { daily, weekly, monthly }

class Habit {
  final String uuid;
  final String name;
  final String? description;
  final int color;
  final String? icon;
  final HabitFrequency frequency;
  final int targetCount;
  final int currentStreak;
  final int longestStreak;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Habit({
    required this.uuid,
    required this.name,
    this.description,
    this.color = 0xFF5865F2,
    this.icon,
    this.frequency = HabitFrequency.daily,
    this.targetCount = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.sortOrder = 0,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Habit copyWith({
    String? uuid,
    String? name,
    String? description,
    int? color,
    String? icon,
    HabitFrequency? frequency,
    int? targetCount,
    int? currentStreak,
    int? longestStreak,
    int? sortOrder,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      frequency: frequency ?? this.frequency,
      targetCount: targetCount ?? this.targetCount,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'frequency': frequency.index,
      'targetCount': targetCount,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'sortOrder': sortOrder,
      'isArchived': isArchived ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as int? ?? 0xFF5865F2,
      icon: map['icon'] as String?,
      frequency: HabitFrequency.values[map['frequency'] as int? ?? 0],
      targetCount: map['targetCount'] as int? ?? 1,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      sortOrder: map['sortOrder'] as int? ?? 0,
      isArchived: (map['isArchived'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
