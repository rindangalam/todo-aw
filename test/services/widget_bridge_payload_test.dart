import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/repositories/task_repository.dart';
import 'package:todoaw/services/widget_bridge.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(setupTestDatabase);
  setUp(initTestDb);
  tearDown(closeTestDb);

  test('payload excludes trash and archives, and includes restored tasks',
      () async {
    final day = DateTime(2026, 10, 31);
    final repo = TaskRepository();
    final done = await createTestTask(
      title: 'Done',
      isCompleted: true,
      dueDate: day.add(const Duration(hours: 8)),
    );
    final pending = await createTestTask(
      title: 'Pending',
      dueDate: day.add(const Duration(hours: 9)),
    );
    final trashed = await createTestTask(title: 'Trashed', dueDate: day);
    final archived = await createTestTask(title: 'Archived', dueDate: day);
    await repo.softDelete(trashed.uuid);
    await repo.update(archived.copyWith(isArchived: true));

    Future<Map<String, String>> payload() => WidgetBridge.buildPayload(
          isDark: false,
          accent: 0xFF0EA5E9,
          taskRepo: repo,
          nowOverride: day,
        );

    List<dynamic> rows(Map<String, String> data) =>
        jsonDecode(data['todayTaskList']!) as List<dynamic>;

    final initial = await payload();
    expect(rows(initial).map((row) => row['uuid']), [done.uuid, pending.uuid]);
    expect(rows(initial).map((row) => row['done']), [true, false]);
    expect(initial['tasksTodayCount'], '1');
    expect(initial['totalTodayCount'], '2');
    expect(initial['totalCount'], '2');
    expect(initial['completedCount'], '1');
    expect(initial['progress'], '50');

    await repo.restore(trashed.uuid);
    final restored = await payload();
    expect(rows(restored).map((row) => row['uuid']),
        [trashed.uuid, done.uuid, pending.uuid]);
    expect(restored['tasksTodayCount'], '2');

    await repo.softDelete(trashed.uuid);
    await repo.emptyTrash();
    expect(await repo.getById(trashed.uuid), isNull);
    final emptied = await payload();
    expect(emptied['todayTaskList'], initial['todayTaskList']);
    expect(emptied['progress'], '50');
  });
}
