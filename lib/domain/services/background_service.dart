import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'task_reminders',
        channelName: 'Task Reminders',
        channelDescription: 'Reminders for your tasks',
        importance: NotificationImportance.High,
        defaultPrivacy: NotificationPrivacy.Public,
        defaultRingtoneType: DefaultRingtoneType.Notification,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        onlyAlertOnce: false,
      ),
    ],
    debug: false,
  );

  service.on('stopService').listen((_) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 15), (_) async {
    await _checkAndFireNotifications();
  });

  await _checkAndFireNotifications();

  debugPrint('[BackgroundService] Started');
}

Future<void> _checkAndFireNotifications() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('pending_notifications');
    if (raw == null) return;

    final pending = List<Map<String, dynamic>>.from(jsonDecode(raw));
    final now = DateTime.now();
    final due = pending
        .where((n) => DateTime.parse(n['scheduledDate'] as String).isBefore(now))
        .toList();

    for (final n in due) {
      debugPrint('[BackgroundService] Firing: ${n['title']}');
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: n['notifId'] as int,
          channelKey: 'task_reminders',
          title: n['title'] as String,
          body: n['body'] as String,
          wakeUpScreen: true,
          autoDismissible: true,
        ),
      );
      pending.remove(n);
    }

    if (due.isNotEmpty) {
      await prefs.setString('pending_notifications', jsonEncode(pending));
    }
  } catch (e) {
    debugPrint('[BackgroundService] Error: $e');
  }
}

class BackgroundNotificationService {
  static Future<void> init() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        foregroundServiceNotificationId: 888,
        initialNotificationTitle: 'Todoaw',
        initialNotificationContent: 'Menunggu pengingat tugas...',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: (_) async => true,
      ),
    );

    final isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
    }

    debugPrint('[BackgroundService] Service configured');
  }

  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke('stopService');
    }
  }

  static Future<bool> isRunning() async {
    final service = FlutterBackgroundService();
    return service.isRunning();
  }
}
