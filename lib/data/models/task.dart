enum Priority { p1, p2, p3, p4 }

class Task {
  final String uuid;
  final String title;
  final String? description;
  final bool isCompleted;
  final Priority priority;
  final String? categoryId;
  final DateTime? dueDate;
  final bool isRecurring;
  final String? recurringRule;
  final String? parentId;
  final bool isArchived;
  final DateTime? deletedAt;
  final int? reminderMinutes;
  final int? estimatedMinutes;
  final bool isTemplate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.uuid,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = Priority.p3,
    this.categoryId,
    this.dueDate,
    this.isRecurring = false,
    this.recurringRule,
    this.parentId,
    this.isArchived = false,
    this.deletedAt,
    this.reminderMinutes,
    this.estimatedMinutes,
    this.isTemplate = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? uuid,
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    String? categoryId,
    DateTime? dueDate,
    bool? isRecurring,
    String? recurringRule,
    String? parentId,
    bool? isArchived,
    DateTime? deletedAt,
    int? reminderMinutes,
    int? estimatedMinutes,
    bool? isTemplate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringRule: recurringRule ?? this.recurringRule,
      parentId: parentId ?? this.parentId,
      isArchived: isArchived ?? this.isArchived,
      deletedAt: deletedAt ?? this.deletedAt,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isTemplate: isTemplate ?? this.isTemplate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority.index,
      'categoryId': categoryId,
      'dueDate': dueDate?.toIso8601String(),
      'isRecurring': isRecurring ? 1 : 0,
      'recurringRule': recurringRule,
      'parentId': parentId,
      'isArchived': isArchived ? 1 : 0,
      'deletedAt': deletedAt?.toIso8601String(),
      'reminderMinutes': reminderMinutes,
      'estimatedMinutes': estimatedMinutes,
      'isTemplate': isTemplate ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      uuid: map['uuid'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['isCompleted'] as int) == 1,
      priority: Priority.values[map['priority'] as int],
      categoryId: map['categoryId'] as String?,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      isRecurring: (map['isRecurring'] as int) == 1,
      recurringRule: map['recurringRule'] as String?,
      parentId: map['parentId'] as String?,
      isArchived: (map['isArchived'] as int) == 1,
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'] as String)
          : null,
      reminderMinutes: map['reminderMinutes'] as int?,
      estimatedMinutes: map['estimatedMinutes'] as int?,
      isTemplate: (map['isTemplate'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
