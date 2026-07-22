import 'package:uuid/uuid.dart';

import '../database.dart';
import '../models/note.dart';

class NoteRepository {
  final _uuid = const Uuid();

  Future<List<Note>> getAll() => AppDatabase.getAllNotes();

  Future<Note?> getById(String uuid) => AppDatabase.getNote(uuid);

  Future<Note> create({
    required String title,
    String? content,
    int color = 0xFFFDE68A,
  }) async {
    final now = DateTime.now();
    final note = Note(
      uuid: _uuid.v4(),
      title: title,
      content: content,
      color: color,
      createdAt: now,
      updatedAt: now,
    );
    await AppDatabase.insertNote(note);
    return note;
  }

  Future<void> update(Note note) async {
    await AppDatabase.updateNote(note.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> delete(String uuid) async {
    await AppDatabase.deleteNote(uuid);
  }

  Future<List<Note>> search(String query) => AppDatabase.searchNotes(query);
}
