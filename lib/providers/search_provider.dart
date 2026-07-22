import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/task.dart';
import '../providers/task_list_provider.dart';
import '../data/repositories/task_repository.dart';

final searchProvider =
    StateNotifierProvider<SearchNotifier, AsyncValue<List<Task>>>((ref) {
  return SearchNotifier(ref.read(taskRepositoryProvider));
});

class SearchNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;
  Timer? _debounce;

  SearchNotifier(this._repository) : super(const AsyncValue.data([]));

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => _repository.search(query.trim()));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
