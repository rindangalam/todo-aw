class Category {
  final String uuid;
  final String name;
  final int color;
  final String? icon;
  final int sortOrder;

  const Category({
    required this.uuid,
    required this.name,
    this.color = 0xFF5B67CA,
    this.icon,
    this.sortOrder = 0,
  });

  Category copyWith({
    String? uuid,
    String? name,
    int? color,
    String? icon,
    int? sortOrder,
  }) {
    return Category(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'color': color,
      'icon': icon,
      'sortOrder': sortOrder,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      color: map['color'] as int? ?? 0xFF5B67CA,
      icon: map['icon'] as String?,
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }
}
