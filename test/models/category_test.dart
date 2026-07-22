import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/models/category.dart';

void main() {
  const baseCategory = Category(
    uuid: 'cat-1',
    name: 'Work',
    color: 0xFF5B67CA,
    icon: 'work',
    sortOrder: 1,
  );

  group('Category constructor', () {
    test('creates with required fields and defaults', () {
      const cat = Category(uuid: 'cat-2', name: 'Personal');
      expect(cat.uuid, 'cat-2');
      expect(cat.name, 'Personal');
      expect(cat.color, 0xFF5B67CA);
      expect(cat.icon, null);
      expect(cat.sortOrder, 0);
    });
  });

  group('Category.copyWith', () {
    test('returns same instance when no args', () {
      final copy = baseCategory.copyWith();
      expect(copy.uuid, baseCategory.uuid);
      expect(copy.name, baseCategory.name);
    });

    test('overrides specified fields', () {
      final copy = baseCategory.copyWith(name: 'Updated', color: 0xFF000000);
      expect(copy.name, 'Updated');
      expect(copy.color, 0xFF000000);
      expect(copy.icon, baseCategory.icon);
    });
  });

  group('Category.toMap / fromMap', () {
    test('round-trip preserves all fields', () {
      final map = baseCategory.toMap();
      final restored = Category.fromMap(map);
      expect(restored.uuid, baseCategory.uuid);
      expect(restored.name, baseCategory.name);
      expect(restored.color, baseCategory.color);
      expect(restored.icon, baseCategory.icon);
      expect(restored.sortOrder, baseCategory.sortOrder);
    });

    test('applies defaults for nullable fields', () {
      final map = <String, dynamic>{
        'uuid': 'cat-3',
        'name': 'Health',
      };
      final restored = Category.fromMap(map);
      expect(restored.color, 0xFF5B67CA);
      expect(restored.icon, null);
      expect(restored.sortOrder, 0);
    });
  });
}
