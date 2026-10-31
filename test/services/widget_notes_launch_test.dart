import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/services/widget_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('home_widget');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  for (final entry in <String, String?>{
    'todoaw://widget/open_note?note_uuid=n-1': '/notes/n-1',
    'todoaw://widget/open_note?uuid=n-legacy': '/notes/n-legacy',
    'todoaw://widget/open_notes': '/notes',
    'todoaw://widget/open_task?uuid=t-1': null,
  }.entries) {
    test('bootstrap honors the notes widget launch intent: ${entry.key}',
        () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'initiallyLaunchedFromHomeWidget');
        return entry.key;
      });
      expect(await initialWidgetNotesLocation(), entry.value);
    });
  }

  test('normal app launch does not override its initial location', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    expect(await initialWidgetNotesLocation(), isNull);
  });

  test('missing platform plugin leaves the normal app launch unchanged',
      () async {
    expect(await initialWidgetNotesLocation(), isNull);
  });
}
