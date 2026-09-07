import 'dart:async';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> onNotificationCreated(ReceivedNotification notification) async {
  debugPrint('[AwesomeNotif] Created: ${notification.title}');
}

@pragma('vm:entry-point')
Future<void> onNotificationDisplayed(ReceivedNotification notification) async {
  debugPrint('[AwesomeNotif] Displayed: ${notification.title}');
}

@pragma('vm:entry-point')
Future<void> onNotificationAction(ReceivedAction action) async {
  debugPrint('[AwesomeNotif] Action tapped: ${action.id} ${action.payload}');
}

class NotificationService {
  static Function(String?)? _onNotificationTap;
  static Timer? _pollTimer;
  static final List<Map<String, dynamic>> _pendingNotifications = [];

  static Future<void> init({Function(String?)? onNotificationTap}) async {
    _onNotificationTap = onNotificationTap;

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
      debug: kDebugMode,
    );

    await AwesomeNotifications().setListeners(
      onNotificationCreatedMethod: onNotificationCreated,
      onNotificationDisplayedMethod: onNotificationDisplayed,
      onActionReceivedMethod: onNotificationAction,
    );

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      final granted = await AwesomeNotifications().requestPermissionToSendNotifications();
      debugPrint('[NotificationService] Permission granted: $granted');
    }

    // Handle notification tap when app was killed
    final initialAction = await AwesomeNotifications().getInitialNotificationAction();
    if (initialAction != null) {
      debugPrint('[NotificationService] Initial action: ${initialAction.id}');
      _onNotificationTap?.call(null);
    }

    // Restore pending from storage
    await _restorePending();

    // Poll every 15 seconds — fire immediately when time is up
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _poll());

    debugPrint('[NotificationService] Init done (awesome_notifications + polling)');
  }

  static Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) return;

    final notifId = id.hashCode & 0x7FFFFFFF;

    // Store for foreground polling (instant fire when time is up)
    _pendingNotifications.removeWhere((n) => n['id'] == id);
    _pendingNotifications.add({
      'id': id,
      'notifId': notifId,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
    });
    await _savePending();

    // Also schedule via WorkManager (survives app kill/reboot)
    try {
      await AwesomeNotifications().createNotification(
        schedule: NotificationCalendar(
          year: scheduledDate.year,
          month: scheduledDate.month,
          day: scheduledDate.day,
          hour: scheduledDate.hour,
          minute: scheduledDate.minute,
          second: 0,
          allowWhileIdle: true,
        ),
        content: NotificationContent(
          id: notifId,
          channelKey: 'task_reminders',
          title: title,
          body: body,
          wakeUpScreen: true,
          autoDismissible: true,
          category: NotificationCategory.Reminder,
        ),
      );
      debugPrint('[NotificationService] Scheduled: $title at $scheduledDate');
    } catch (e) {
      debugPrint('[NotificationService] WorkManager schedule failed: $e');
    }
  }

  static void _poll() {
    final now = DateTime.now();
    final due = _pendingNotifications
        .where((n) => DateTime.parse(n['scheduledDate'] as String).isBefore(now))
        .toList();

    for (final n in due) {
      debugPrint('[NotificationService] Poll firing: ${n['title']}');
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: n['notifId'] as int,
          channelKey: 'task_reminders',
          title: n['title'] as String,
          body: n['body'] as String,
          wakeUpScreen: true,
          autoDismissible: true,
        ),
      );
      _pendingNotifications.remove(n);
    }

    if (due.isNotEmpty) {
      _savePending();
    }
  }

  static Future<void> cancelNotification(String id) async {
    final notifId = id.hashCode & 0x7FFFFFFF;
    _pendingNotifications.removeWhere((n) => n['id'] == id);
    await _savePending();
    await AwesomeNotifications().cancel(notifId);
  }

  static Future<void> cancelAll() async {
    _pendingNotifications.clear();
    await _savePending();
    await AwesomeNotifications().cancelAll();
  }

  static Future<void> showImmediate({
    required String title,
    required String body,
  }) async {
    debugPrint('[NotificationService] Showing immediately: $title');
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
        channelKey: 'task_reminders',
        title: title,
        body: body,
        wakeUpScreen: true,
        autoDismissible: true,
      ),
    );
  }

  static Future<void> _savePending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_notifications', jsonEncode(_pendingNotifications));
    } catch (_) {}
  }

  static Future<void> _restorePending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('pending_notifications');
      if (raw != null) {
        _pendingNotifications.clear();
        _pendingNotifications.addAll(List<Map<String, dynamic>>.from(jsonDecode(raw)));
      }
    } catch (_) {}
  }

  static void dispose() {
    _pollTimer?.cancel();
  }
}
