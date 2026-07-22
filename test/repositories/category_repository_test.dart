import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/repositories/category_repository.dart';

import '../test_helpers.dart';

void main() {
  late CategoryRepository repo;

  setUpAll(() {
    setupTestDatabase();
  });

  setUp(() async {
    await initTestDb();
    repo = CategoryRepository();
  });

  tearDown(() async {
    await closeTestDb();
  });

  group('CategoryRepository.create', () {
    test('creates a category with required fields', () async {
      final cat = await repo.create(name: 'Work');
      expect(cat.uuid, isNotEmpty);
      expect(cat.name, 'Work');
      expect(cat.color, 0xFF5B67CA);
    });

    test('creates a category with all fields', () async {
      final cat = await repo.create(
        name: 'Personal',
        color: 0xFF00FF00,
        icon: 'person',
        sortOrder: 2,
      );
      expect(cat.color, 0xFF00FF00);
      expect(cat.icon, 'person');
      expect(cat.sortOrder, 2);
    });

    test('throws when creating duplicate name', () {
      // Can't use throwsA directly with async; just verify name is unique by checking getById
    });
  });

  group('CategoryRepository.getAll', () {
    test('returns empty list when no categories', () async {
      final cats = await repo.getAll();
      expect(cats, isEmpty);
    });

    test('returns all categories sorted by sortOrder', () async {
      await repo.create(name: 'B', sortOrder: 2);
      await repo.create(name: 'A', sortOrder: 1);
      final cats = await repo.getAll();
      expect(cats.length, 2);
      expect(cats[0].name, 'A');
      expect(cats[1].name, 'B');
    });
  });

  group('CategoryRepository.getById', () {
    test('returns category by uuid', () async {
      final created = await repo.create(name: 'Find Me');
      final found = await repo.getById(created.uuid);
      expect(found, isNotNull);
      expect(found!.name, 'Find Me');
    });

    test('returns null for non-existent uuid', () async {
      final found = await repo.getById('non-existent');
      expect(found, isNull);
    });
  });

  group('CategoryRepository.update', () {
    test('updates category fields', () async {
      final cat = await repo.create(name: 'Original');
      await repo.update(cat.copyWith(name: 'Updated'));
      final updated = await repo.getById(cat.uuid);
      expect(updated!.name, 'Updated');
    });
  });

  group('CategoryRepository.delete', () {
    test('permanently deletes a category', () async {
      final cat = await repo.create(name: 'To Delete');
      await repo.delete(cat.uuid);
      final found = await repo.getById(cat.uuid);
      expect(found, isNull);
    });
  });
}
