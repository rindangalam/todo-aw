import 'package:flutter/services.dart';

import '../data/repositories/note_repository.dart';
import '../data/repositories/task_repository.dart';
import 'widget_bridge.dart';

const MethodChannel widgetQuickChannel = MethodChannel('todoaw/widget');

/// Handles Kotlin → Dart `saveQuick` (warm path from QuickInputActivity).
Future<void> setupWidgetQuickInputChannel() async {
  widgetQuickChannel.setMethodCallHandler((call) async {
    if (call.method == 'saveQuick') {
      return _saveQuick((call.arguments as Map).cast<String, dynamic>());
    }
    throw MissingPluginException();
  });
  await drainPendingQuickInput();
}

/// Cold path: QuickInputActivity stashed payload in HomeWidgetPreferences and
/// launched MainActivity; pull and clear it via MainActivity's handler.
Future<void> drainPendingQuickInput() async {
  try {
    final pending = await widgetQuickChannel.invokeMethod('getPendingQuickInput');
    if (pending is Map) {
      await _saveQuick(pending.cast<String, dynamic>());
    }
  } catch (_) {
    // Channel not ready (e.g. non-Android) — ignore.
  }
}

Future<Map<String, Object?>> _saveQuick(Map<String, dynamic> args) async {
  final mode = args['mode'] as String? ?? '';
  final title = (args['title'] as String? ?? '').trim();
  final time = args['time'] as String?;
  if (title.isEmpty) {
    return {'ok': false, 'error': 'Judul tidak boleh kosong'};
  }
  try {
    if (mode == 'task') {
      await TaskRepository().create(title: title, dueDate: _parseTime(time));
    } else if (mode == 'note') {
      await NoteRepository().create(title: title);
    } else {
      return {'ok': false, 'error': 'Mode tidak dikenal'};
    }
    await refreshWidgetsFromPrefs();
    return {'ok': true};
  } catch (e) {
    return {'ok': false, 'error': 'Gagal menyimpan: $e'};
  }
}

DateTime? _parseTime(String? time) {
  if (time == null || !time.contains(':')) return null;
  final parts = time.split(':');
  final h = int.tryParse(parts[0]);
  final m = parts.length > 1 ? int.tryParse(parts[1]) : null;
  if (h == null || m == null) return null;
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, h, m);
}
