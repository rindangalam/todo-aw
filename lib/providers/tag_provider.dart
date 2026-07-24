import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/models/tag.dart';
import '../data/repositories/tag_repository.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository();
});

final tagListProvider =
    StateNotifierProvider<TagListNotifier, AsyncValue<List<Tag>>>((ref) {
  return TagListNotifier(ref.read(tagRepositoryProvider));
});

class TagListNotifier extends StateNotifier<AsyncValue<List<Tag>>> {
  final TagRepository _repository;

  TagListNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAll());
  }

  Future<void> create({
    required String name,
    int color = 0xFF6366F1,
  }) async {
    await _repository.create(name: name, color: color);
    await load();
  }

  Future<void> update(Tag tag) async {
    await _repository.update(tag);
    await load();
  }

  Future<void> delete(String uuid) async {
    await _repository.delete(uuid);
    await load();
  }
}

final taskTagMapProvider =
    FutureProvider<Map<String, Set<String>>>((ref) async {
  final repo = ref.read(tagRepositoryProvider);
  final tags = await repo.getAll();
  final map = <String, Set<String>>{};
  for (final tag in tags) {
    final taskIds = await AppDatabase.getTaskIdsByTag(tag.uuid);
    for (final taskId in taskIds) {
      map.putIfAbsent(taskId, () => {});
      map[taskId]!.add(tag.uuid);
    }
  }
  return map;
});
