// ignore_for_file: deprecated_member_use

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/domain/services/notification_service.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUpAll(() {
    registerFallbackValue(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
    registerFallbackValue(const NotificationDetails(
      android: AndroidNotificationDetails('a', 'b'),
      iOS: DarwinNotificationDetails(),
    ));
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    NotificationService.plugin = mockPlugin;
  });

  tearDown(() {
    NotificationService.plugin = FlutterLocalNotificationsPlugin();
  });

  group('init', () {
    test('calls initialize on plugin', () async {
      when(() => mockPlugin.initialize(any())).thenAnswer((_) async => null);

      await NotificationService.init();

      verify(() => mockPlugin.initialize(any())).called(1);
    });
  });

  group('scheduleNotification', () {
    test('schedules notification for future date', () async {
      when(() => mockPlugin.schedule(
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async {});

      await NotificationService.scheduleNotification(
        id: 'test-id',
        title: 'Test Title',
        body: 'Test Body',
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
      );

      verify(() => mockPlugin.schedule(
            'test-id'.hashCode,
            'Test Title',
            'Test Body',
            any(),
            any(),
          )).called(1);
    });

    test('does not schedule for past date', () async {
      await NotificationService.scheduleNotification(
        id: 'test-id',
        title: 'Test',
        body: 'Body',
        scheduledDate: DateTime.now().subtract(const Duration(hours: 1)),
      );

      verifyNever(() => mockPlugin.schedule(
            any(),
            any(),
            any(),
            any(),
            any(),
          ));
    });

    test('catches exceptions from plugin', () async {
      when(() => mockPlugin.schedule(
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenThrow(Exception('plugin error'));

      await NotificationService.scheduleNotification(
        id: 'test-id',
        title: 'Test',
        body: 'Body',
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
      );
    });
  });

  group('cancelNotification', () {
    test('calls cancel on plugin with id hash', () async {
      when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});

      await NotificationService.cancelNotification('test-id');

      verify(() => mockPlugin.cancel('test-id'.hashCode)).called(1);
    });
  });

  group('cancelAll', () {
    test('calls cancelAll on plugin', () async {
      when(() => mockPlugin.cancelAll()).thenAnswer((_) async {});

      await NotificationService.cancelAll();

      verify(() => mockPlugin.cancelAll()).called(1);
    });
  });
}
