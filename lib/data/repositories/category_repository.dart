import 'package:uuid/uuid.dart';

import '../database.dart';
import '../models/category.dart';

class CategoryRepository {
  final _uuid = const Uuid();

  Future<List<Category>> getAll() => AppDatabase.getAllCategories();

  Future<Category?> getById(String uuid) => AppDatabase.getCategory(uuid);

  Future<Category> create({
    required String name,
    int color = 0xFF5B67CA,
    String? icon,
    int sortOrder = 0,
  }) async {
    final category = Category(
      uuid: _uuid.v4(),
      name: name,
      color: color,
      icon: icon,
      sortOrder: sortOrder,
    );
    await AppDatabase.insertCategory(category);
    return category;
  }

  Future<void> update(Category category) async {
    await AppDatabase.updateCategory(category);
  }

  Future<void> delete(String uuid) async {
    await AppDatabase.deleteCategory(uuid);
  }
}
