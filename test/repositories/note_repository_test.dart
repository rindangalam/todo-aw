import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/models/note.dart';
import 'package:todoaw/data/repositories/note_repository.dart';

import '../test_helpers.dart';

void main() {
  late NoteRepository repo;

  setUpAll(() {
    setupTestDatabase();
  });

  setUp(() async {
    await initTestDb();
    repo = NoteRepository();
  });

  tearDown(() async {
    await closeTestDb();
  });

  group('NoteRepository', () {
    test('create and getAll', () async {
      final note = await repo.create(title: 'Test Note', content: 'Hello');
      expect(note.title, 'Test Note');
      expect(note.content, 'Hello');
      expect(note.isPinned, false);

      final all = await repo.getAll();
      expect(all.any((n) => n.uuid == note.uuid), true);
    });

    test('getById returns null for missing note', () async {
      final result = await repo.getById('nonexistent');
      expect(result, isNull);
    });

    test('update modifies note', () async {
      final note = await repo.create(title: 'Original');
      await repo.update(note.copyWith(title: 'Updated'));
      final updated = await repo.getById(note.uuid);
      expect(updated?.title, 'Updated');
    });

    test('delete removes note', () async {
      final note = await repo.create(title: 'To Delete');
      await repo.delete(note.uuid);
      final result = await repo.getById(note.uuid);
      expect(result, isNull);
    });

    test('search finds notes by title', () async {
      await repo.create(title: 'Meeting Notes');
      await repo.create(title: 'Shopping List');

      final results = await repo.search('Meeting');
      expect(results.length, 1);
      expect(results.first.title, 'Meeting Notes');
    });
  });
}
