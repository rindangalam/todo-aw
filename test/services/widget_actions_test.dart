import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/services/widget_actions.dart';

void main() {
  setUp(PendingWidgetAction.clear);

  group('applyWidgetUri', () {
    test('parses toggle_task with task uuid', () {
      applyWidgetUri(
        Uri.parse('todoaw://widget/toggle_task?uuid=t-1'),
      );
      expect(PendingWidgetAction.action, WidgetActions.toggleTask);
      expect(PendingWidgetAction.taskUuid, 't-1');
      expect(PendingWidgetAction.noteUuid, isNull);
    });

    test('parses open_note with note uuid', () {
      applyWidgetUri(
        Uri.parse('todoaw://widget/open_note?note_uuid=n-9'),
      );
      expect(PendingWidgetAction.action, WidgetActions.openNote);
      expect(PendingWidgetAction.noteUuid, 'n-9');
      expect(PendingWidgetAction.taskUuid, isNull);
    });

    test('accepts legacy open_note uuid from existing widget intents', () {
      applyWidgetUri(Uri.parse('todoaw://widget/open_note?uuid=n-legacy'));
      expect(PendingWidgetAction.noteUuid, 'n-legacy');
    });

    test('parses action without extras', () {
      applyWidgetUri(Uri.parse('todoaw://widget/open_notes'));
      expect(PendingWidgetAction.action, WidgetActions.openNotes);
      expect(PendingWidgetAction.taskUuid, isNull);
    });

    test('null uri is a no-op', () {
      PendingWidgetAction.action = WidgetActions.openHome;
      applyWidgetUri(null);
      expect(PendingWidgetAction.action, WidgetActions.openHome);
    });

    test('empty uri (no scheme/path) is a no-op', () {
      applyWidgetUri(Uri());
      expect(PendingWidgetAction.action, isNull);
    });

    test('fires widgetActionEvents', () async {
      final event = widgetActionEvents.first;
      applyWidgetUri(Uri.parse('todoaw://widget/open_dashboard'));
      await event;
      expect(PendingWidgetAction.action, WidgetActions.openDashboard);
    });
  });

  group('PendingWidgetAction', () {
    test('clear resets all fields', () {
      PendingWidgetAction.action = WidgetActions.toggleTask;
      PendingWidgetAction.taskUuid = 't-1';
      PendingWidgetAction.noteUuid = 'n-1';
      PendingWidgetAction.clear();
      expect(PendingWidgetAction.action, isNull);
      expect(PendingWidgetAction.taskUuid, isNull);
      expect(PendingWidgetAction.noteUuid, isNull);
    });
  });

  group('widgetRedirect', () {
    test('cold notes clicks navigate directly without a pending Home action',
        () {
      expect(widgetRedirect(Uri.parse('todoaw://widget/open_notes')), '/notes');
      expect(
        widgetRedirect(Uri.parse('todoaw://widget/open_note?note_uuid=n-9')),
        '/notes/n-9',
      );
      expect(PendingWidgetAction.action, isNull);
    });

    test('warm note pushes preserve the selected note, including legacy uuid',
        () {
      for (final key in ['note_uuid', 'uuid']) {
        expect(widgetRedirect(Uri.parse('/open_note?$key=n-9')), '/notes/n-9');
      }
      expect(PendingWidgetAction.action, isNull);
    });

    test('missing note ID falls back to Notes, never Home', () {
      expect(widgetRedirect(Uri.parse('todoaw://widget/open_note')), '/notes');
      expect(widgetRedirect(Uri.parse('/open_note?uuid=')), '/notes');
    });

    test('note ID is encoded as one route segment', () {
      expect(
        widgetRedirect(Uri(
          scheme: 'todoaw',
          host: 'widget',
          path: '/open_note',
          queryParameters: {'note_uuid': 'note/with spaces'},
        )),
        '/notes/note%2Fwith%20spaces',
      );
    });

    test('full-form cold URI applies action and returns home', () {
      final redirect = widgetRedirect(
        Uri.parse('todoaw://widget/toggle_task?uuid=t-7'),
      );
      expect(redirect, '/');
      expect(PendingWidgetAction.action, WidgetActions.toggleTask);
      expect(PendingWidgetAction.taskUuid, 't-7');
    });

    test('path-only warm push returns home without applying', () {
      final redirect = widgetRedirect(Uri.parse('/toggle_task?uuid=t-7'));
      expect(redirect, '/');
      expect(PendingWidgetAction.action, isNull);
    });

    test('path-only open_notes maps to the real notes route', () {
      final redirect = widgetRedirect(Uri.parse('/open_notes'));
      expect(redirect, '/notes');
      expect(PendingWidgetAction.action, isNull);
    });

    test('path-only open_dashboard maps to the real dashboard route', () {
      expect(widgetRedirect(Uri.parse('/open_dashboard')), '/dashboard');
    });

    test('real app routes pass through untouched', () {
      for (final path in [
        '/',
        '/notes',
        '/dashboard',
        '/calendar',
        '/settings',
        '/splash',
      ]) {
        expect(widgetRedirect(Uri.parse(path)), isNull, reason: path);
      }
      expect(PendingWidgetAction.action, isNull);
    });

    test('foreign scheme is ignored', () {
      expect(
        widgetRedirect(Uri.parse('https://evil.example/open_notes')),
        isNull,
      );
      expect(PendingWidgetAction.action, isNull);
    });
  });

  group('handleWidgetClick', () {
    test('navigates notes from any tab without a HomeScreen listener', () {
      final destinations = <String>[];
      for (final uri in [
        'todoaw://widget/open_notes',
        'todoaw://widget/open_note?uuid=n-old',
        'todoaw://widget/open_note?note_uuid=n-new',
      ]) {
        handleWidgetClick(Uri.parse(uri), navigate: destinations.add);
      }
      expect(destinations, ['/notes', '/notes/n-old', '/notes/n-new']);
      expect(PendingWidgetAction.action, isNull);
    });

    test('keeps task actions on the existing action stream', () {
      final destinations = <String>[];
      handleWidgetClick(
        Uri.parse('todoaw://widget/open_task?uuid=t-1'),
        navigate: destinations.add,
      );
      expect(destinations, isEmpty);
      expect(PendingWidgetAction.action, WidgetActions.openTask);
      expect(PendingWidgetAction.taskUuid, 't-1');
    });
  });
}
