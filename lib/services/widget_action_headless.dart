import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../domain/services/notification_service.dart';
import '../providers/task_list_provider.dart';
import 'widget_bridge.dart';

const MethodChannel widgetActionChannel = MethodChannel('todoaw/widget_action');

Future<void>? _databaseReady;

Future<void> _ensureDatabase() {
  return _databaseReady ??= () async {
    try {
      await AppDatabase.init();
    } catch (_) {
      // Best-effort: if storage is unavailable the toggle below degrades to
      // a resync-only no-op instead of crashing the headless isolate.
    }
    try {
      await SharedPreferences.getInstance();
    } catch (_) {}
  }();
}

/// Body of the cold-path entrypoint. The entrypoint symbol itself
/// (`widgetActionHeadless`) is declared in lib/main.dart because named
/// DartEntrypoints resolve against Dart_RootLibrary() only.
void runWidgetActionHeadless() {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  widgetActionChannel.setMethodCallHandler((call) async {
    if (call.method != 'toggleTask') return false;
    final args = (call.arguments as Map?)?.cast<String, dynamic>();
    final uuid = args?['uuid'] as String?;
    if (uuid == null || uuid.isEmpty) return false;
    try {
      await _ensureDatabase();
      try {
        await NotificationService.init();
      } catch (_) {
        // Notification scheduling is best-effort in the background.
      }
      final notifier = container.read(taskListProvider.notifier);
      var tasks = container.read(taskListProvider).value;
      if (tasks == null) {
        await notifier.refresh();
        tasks = container.read(taskListProvider).value ?? [];
      }
      final match = tasks.where((t) => t.uuid == uuid).firstOrNull;
      if (match != null) {
        await notifier.toggleComplete(match);
      } else {
        // Completed/archived or stale reference - resync only.
        await notifier.refresh();
      }
      // The receiver destroys this engine the instant `true` is returned, so
      // the widget snapshot push must be awaited HERE - toggleComplete's own
      // unawaited() push would be killed mid-flight.
      try {
        await refreshWidgetsFromPrefs();
      } catch (_) {
        // Push is best-effort; the next app open/CRUD path re-syncs widgets.
      }
      return true;
    } catch (e) {
      debugPrint('[WidgetActionHeadless] toggle failed: $e');
      return false;
    }
  });
  widgetActionChannel.invokeMethod('ready').ignore();
}
