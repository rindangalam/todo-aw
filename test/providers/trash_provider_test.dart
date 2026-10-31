import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/data/repositories/task_repository.dart';
import 'package:todoaw/presentation/screens/trash_screen.dart';
import 'package:todoaw/providers/task_list_provider.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(setupTestDatabase);
  setUp(initTestDb);
  tearDown(closeTestDb);

  test('reopening Trash fetches tasks deleted after the previous visit',
      () async {
    final repo = TaskRepository();
    final task = await createTestTask();
    final container = ProviderContainer(overrides: [
      taskRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);

    final firstVisit = container.listen<AsyncValue<List<Task>>>(
      trashListProvider,
      (_, __) {},
    );
    expect(await container.read(trashListProvider.future), isEmpty);
    firstVisit.close();
    await container.pump();

    await repo.softDelete(task.uuid);
    final secondVisit = container.listen<AsyncValue<List<Task>>>(
      trashListProvider,
      (_, __) {},
    );
    addTearDown(secondVisit.close);
    final trashed = await container.read(trashListProvider.future);
    expect(trashed.map((t) => t.uuid), [task.uuid]);
  });
}
