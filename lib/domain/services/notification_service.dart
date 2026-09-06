// ignore_for_file: deprecated_member_use

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @visibleForTesting
  static set plugin(FlutterLocalNotificationsPlugin p) => _plugin = p;

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {}
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);

    // Request notification permission for Android 13+
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('[NotificationService] Permission granted: $granted');
      await androidPlugin.requestExactAlarmsPermission();
    }

    // Check pending notifications
    final pending = await _plugin.pendingNotificationRequests();
    debugPrint('[NotificationService] Pending: ${pending.length}');
  }

  static Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Reminders for your tasks',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      ongoing: false,
      icon: '@mipmap/ic_launcher',
      styleInformation: DefaultStyleInformation(true, true),
      ticker: 'Todoaw',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    final delay = scheduledDate.difference(now);
    if (delay.isNegative || delay.inSeconds < 0) return;

    try {
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
      debugPrint('[NotificationService] Scheduling: $title at $tzDate');
      await _plugin.zonedSchedule(
        (id.hashCode & 0x7FFFFFFF),
        title,
        body,
        tzDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('[NotificationService] Scheduled OK');
    } catch (e) {
      debugPrint('[NotificationService] ERROR: $e');
    }
  }

  static Future<void> cancelNotification(String id) async {
    await _plugin.cancel(id.hashCode & 0x7FFFFFFF);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> showImmediate({
    required String title,
    required String body,
    String channelId = 'task_reminders',
    String channelName = 'Task Reminders',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Reminders for your tasks',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      autoCancel: true,
      ongoing: false,
      largeIcon: null,
      icon: '@mipmap/ic_launcher',
      styleInformation: DefaultStyleInformation(true, true),
      ticker: 'Todoaw',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
    );
  }
}
