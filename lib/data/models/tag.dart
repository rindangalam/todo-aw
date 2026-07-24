class Tag {
  final String uuid;
  final String name;
  final int color;

  const Tag({
    required this.uuid,
    required this.name,
    this.color = 0xFF6366F1,
  });

  Tag copyWith({
    String? uuid,
    String? name,
    int? color,
  }) {
    return Tag(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'color': color,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      color: map['color'] as int? ?? 0xFF6366F1,
    );
  }
}
