import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/note.dart';
import '../data/repositories/note_repository.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

final noteListProvider =
    StateNotifierProvider<NoteListNotifier, AsyncValue<List<Note>>>((ref) {
  return NoteListNotifier(ref.read(noteRepositoryProvider));
});

final archivedNoteListProvider = FutureProvider<List<Note>>((ref) {
  return ref.read(noteRepositoryProvider).getArchived();
});

class NoteListNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final NoteRepository _repository;

  NoteListNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAll());
  }

  Future<void> create({
    required String title,
    String? content,
    int color = 0xFFFDE68A,
    bool isPinned = false,
  }) async {
    await _repository.create(
      title: title,
      content: content,
      color: color,
      isPinned: isPinned,
    );
    await load();
  }

  Future<void> update(Note note) async {
    state = AsyncValue.data(
      (state.value ?? []).map((n) => n.uuid == note.uuid ? note : n).toList(),
    );
    await _repository.update(note);
    await load();
  }

  Future<void> togglePin(Note note) async {
    await _repository.update(note.copyWith(isPinned: !note.isPinned));
    await load();
  }

  Future<void> delete(Note note) async {
    state = AsyncValue.data(
      (state.value ?? []).where((n) => n.uuid != note.uuid).toList(),
    );
    await _repository.delete(note.uuid);
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      await load();
    } else {
      state = await AsyncValue.guard(() => _repository.search(query));
    }
  }
}
