class Note {
  final String uuid;
  final String title;
  final String? content;
  final int color;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.uuid,
    required this.title,
    this.content,
    this.color = 0xFFFDE68A,
    this.isPinned = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? uuid,
    String? title,
    String? content,
    int? color,
    bool? isPinned,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'title': title,
      'content': content,
      'color': color,
      'isPinned': isPinned ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      uuid: map['uuid'] as String,
      title: map['title'] as String,
      content: map['content'] as String?,
      color: map['color'] as int? ?? 0xFFFDE68A,
      isPinned: (map['isPinned'] as int?) == 1,
      isArchived: (map['isArchived'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
