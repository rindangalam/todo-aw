// ignore_for_file: deprecated_member_use

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @visibleForTesting
  static set plugin(FlutterLocalNotificationsPlugin p) => _plugin = p;

  static Future<void> init() async {
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
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
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
      await _plugin.schedule(
        id.hashCode,
        title,
        body,
        scheduledDate,
        details,
      );
    } catch (_) {}
  }

  static Future<void> cancelNotification(String id) async {
    await _plugin.cancel(id.hashCode);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> showImmediate({
    required String title,
    required String body,
    String channelId = 'general',
    String channelName = 'Notifications',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'focus_timer',
      'Focus Timer',
      channelDescription: 'Focus session completion alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
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
