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
}
