import 'package:uuid/uuid.dart';

import '../database.dart';
import '../models/tag.dart';

class TagRepository {
  final _uuid = const Uuid();

  Future<List<Tag>> getAll() => AppDatabase.getAllTags();

  Future<Tag?> getById(String uuid) => AppDatabase.getTag(uuid);

  Future<Tag> create({
    required String name,
    int color = 0xFF6366F1,
  }) async {
    final tag = Tag(
      uuid: _uuid.v4(),
      name: name,
      color: color,
    );
    await AppDatabase.insertTag(tag);
    return tag;
  }

  Future<void> update(Tag tag) async {
    await AppDatabase.updateTag(tag);
  }

  Future<void> delete(String uuid) async {
    await AppDatabase.deleteTag(uuid);
  }

  Future<List<String>> getTaskTags(String taskId) async {
    final taskTags = await AppDatabase.getTaskTags(taskId);
    return taskTags.map((t) => t.tagId).toList();
  }

  Future<void> setTaskTags(String taskId, List<String> tagIds) async {
    await AppDatabase.setTaskTags(taskId, tagIds);
  }
}
