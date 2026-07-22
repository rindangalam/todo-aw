import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/repositories/focus_repository.dart';

import '../test_helpers.dart';

void main() {
  late FocusRepository repo;

  setUpAll(() {
    setupTestDatabase();
  });

  setUp(() async {
    await initTestDb();
    repo = FocusRepository();
  });

  tearDown(() async {
    await closeTestDb();
  });

  group('FocusRepository', () {
    test('create and getAll', () async {
      final session = await repo.create(durationMinutes: 25);
      expect(session.durationMinutes, 25);
      expect(session.isCompleted, false);

      final all = await repo.getAll();
      expect(all.any((s) => s.uuid == session.uuid), true);
    });

    test('complete marks session as done', () async {
      final session = await repo.create(durationMinutes: 15);
      await repo.complete(session.uuid);

      final all = await repo.getAll();
      final updated = all.firstWhere((s) => s.uuid == session.uuid);
      expect(updated.isCompleted, true);
      expect(updated.endedAt, isNotNull);
    });

    test('cancel removes session', () async {
      final session = await repo.create(durationMinutes: 25);
      await repo.cancel(session.uuid);

      final all = await repo.getAll();
      expect(all.any((s) => s.uuid == session.uuid), false);
    });

    test('getTodayTotalMinutes returns 0 when no sessions', () async {
      final total = await repo.getTodayTotalMinutes();
      expect(total, 0);
    });
  });
}
