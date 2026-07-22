import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/core/l10n/strings.dart';
import 'package:todoaw/core/theme.dart';
import 'package:todoaw/data/models/note.dart';
import 'package:todoaw/providers/note_provider.dart';
import 'package:todoaw/data/repositories/note_repository.dart';
import 'package:todoaw/presentation/screens/notes_screen.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

Widget createTestApp({
  required NoteRepository noteRepo,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(noteRepo),
      ],
      child: const NotesScreen(),
    ),
  );
}

void main() {
  late MockNoteRepository noteRepo;

  setUp(() {
    noteRepo = MockNoteRepository();
  });

  group('NotesScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      when(() => noteRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(noteRepo: noteRepo));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no notes', (tester) async {
      when(() => noteRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(noteRepo: noteRepo));
      await tester.pumpAndSettle();

      expect(find.text(S.notesKosong), findsOneWidget);
      expect(find.text(S.notesBuatPertama), findsOneWidget);
    });

    testWidgets('shows notes in grid', (tester) async {
      final now = DateTime.now();
      when(() => noteRepo.getAll()).thenAnswer((_) async => [
            Note(
              uuid: '1',
              title: 'First Note',
              content: 'Hello world',
              createdAt: now,
              updatedAt: now,
            ),
            Note(
              uuid: '2',
              title: 'Second Note',
              createdAt: now,
              updatedAt: now,
            ),
          ]);

      await tester.pumpWidget(createTestApp(noteRepo: noteRepo));
      await tester.pumpAndSettle();

      expect(find.text('First Note'), findsOneWidget);
      expect(find.text('Second Note'), findsOneWidget);
    });

    testWidgets('shows pinned section', (tester) async {
      final now = DateTime.now();
      when(() => noteRepo.getAll()).thenAnswer((_) async => [
            Note(
              uuid: '1',
              title: 'Pinned',
              isPinned: true,
              createdAt: now,
              updatedAt: now,
            ),
            Note(
              uuid: '2',
              title: 'Unpinned',
              createdAt: now,
              updatedAt: now,
            ),
          ]);

      await tester.pumpWidget(createTestApp(noteRepo: noteRepo));
      await tester.pumpAndSettle();

      expect(find.text(S.notesDisematkan), findsOneWidget);
    });

    testWidgets('search icon toggles search bar', (tester) async {
      when(() => noteRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(noteRepo: noteRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
