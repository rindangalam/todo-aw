import 'dart:async';

/// Widget action strings shared by bridge, receivers, and UI.
class WidgetActions {
  WidgetActions._();

  static const openHome = 'open_home';
  static const openNotes = 'open_notes';
  static const openDashboard = 'open_dashboard';
  static const openTasksPriority = 'open_tasks_priority';
  static const openTask = 'open_task';
  static const openNote = 'open_note';
  static const toggleTask = 'toggle_task';
  static const newTask = 'new_task';
  static const newNote = 'new_note';
}

/// One-shot action payload set by home_widget click/receiver before UI handles it.
class PendingWidgetAction {
  static String? action;
  static String? taskUuid;
  static String? noteUuid;

  static void clear() {
    action = null;
    taskUuid = null;
    noteUuid = null;
  }
}

final StreamController<void> _widgetActionEvents =
    StreamController<void>.broadcast();

/// Fires whenever [PendingWidgetAction] is filled from a widget click URI.
Stream<void> get widgetActionEvents => _widgetActionEvents.stream;

/// Parses a home_widget click URI (`todoaw://widget/<action>?uuid=...`) into
/// [PendingWidgetAction] and notifies [widgetActionEvents] listeners.
void applyWidgetUri(Uri? uri) {
  if (uri == null) return;
  final action =
      uri.pathSegments.isNotEmpty ? uri.pathSegments.first : uri.host;
  if (action.isEmpty) return;
  PendingWidgetAction.action = action;
  PendingWidgetAction.taskUuid = uri.queryParameters['uuid'];
  PendingWidgetAction.noteUuid = uri.queryParameters['note_uuid'];
  if (!_widgetActionEvents.isClosed) _widgetActionEvents.add(null);
}
