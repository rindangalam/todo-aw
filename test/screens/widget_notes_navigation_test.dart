import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoaw/core/l10n/strings.dart';
import 'package:todoaw/data/models/note.dart';
import 'package:todoaw/data/repositories/note_repository.dart';
import 'package:todoaw/presentation/router.dart';
import 'package:todoaw/presentation/screens/notes_screen.dart';
import 'package:todoaw/presentation/widgets/note_form_sheet.dart';
import 'package:todoaw/providers/note_provider.dart';
import 'package:todoaw/services/widget_actions.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  setUp(() {
    PendingWidgetAction.clear();
    SharedPreferences.setMockInitialValues({'tour_coachmark_notes': true});
  });

  for (final uri in [
    'todoaw://widget/open_note?note_uuid=n-9',
    '/open_note?uuid=n-9',
  ]) {
    testWidgets(
        'widget route opens the selected note and closes to Notes: $uri',
        (tester) async {
      final now = DateTime.now();
      final note = Note(
        uuid: 'n-9',
        title: 'Selected widget note',
        content: 'Correct note content',
        createdAt: now,
        updatedAt: now,
      );
      final repo = MockNoteRepository();
      when(repo.getAll).thenAnswer((_) async => [note]);
      when(() => repo.getById(note.uuid)).thenAnswer((_) async => note);
      final other = note.copyWith(
        uuid: 'n-other',
        title: 'Another widget note',
        content: 'Another note content',
      );
      when(() => repo.getById(other.uuid)).thenAnswer((_) async => other);
      final router = appRouter(initialLocation: uri);
      addTearDown(router.dispose);

      await tester.pumpWidget(ProviderScope(
        overrides: [noteRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(NoteFormSheet), findsOneWidget);
      expect(find.text('Selected widget note'), findsOneWidget);
      expect(find.text('Correct note content'), findsOneWidget);
      expect(PendingWidgetAction.action, isNull);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(NoteFormSheet), findsNothing);
      expect(find.byType(NotesScreen), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(AppBar), matching: find.text(S.notesTitle)),
          findsOneWidget);

      // A second warm widget click must reopen the note, not replay Home.
      handleWidgetClick(Uri.parse(uri), navigate: router.go);
      await tester.pumpAndSettle();
      expect(find.byType(NoteFormSheet), findsOneWidget);
      expect(find.text('Correct note content'), findsOneWidget);

      // Clicking another card while an editor is already open must load that
      // note, rather than retaining the previous editor's controllers.
      handleWidgetClick(
        Uri.parse('todoaw://widget/open_note?note_uuid=n-other'),
        navigate: router.go,
      );
      await tester.pumpAndSettle();
      expect(find.text('Another note content'), findsOneWidget);
      expect(find.text('Correct note content'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
