import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/category.dart';
import '../data/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, AsyncValue<List<Category>>>(
        (ref) {
  return CategoryListNotifier(ref.read(categoryRepositoryProvider));
});

class CategoryListNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository _repository;

  CategoryListNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAll());
  }

  Future<void> create({
    required String name,
    int color = 0xFF5B67CA,
    String? icon,
  }) async {
    await _repository.create(name: name, color: color, icon: icon);
    await load();
  }

  Future<void> update(Category category) async {
    await _repository.update(category);
    await load();
  }

  Future<void> delete(String uuid) async {
    await _repository.delete(uuid);
    await load();
  }
}
