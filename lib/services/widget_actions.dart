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
  PendingWidgetAction.noteUuid = uri.queryParameters['note_uuid'] ??
      (action == WidgetActions.openNote ? uri.queryParameters['uuid'] : null);
  if (!_widgetActionEvents.isClosed) _widgetActionEvents.add(null);
}

const Set<String> _widgetActionNames = {
  WidgetActions.openHome,
  WidgetActions.openNotes,
  WidgetActions.openDashboard,
  WidgetActions.openTasksPriority,
  WidgetActions.openTask,
  WidgetActions.openNote,
  WidgetActions.toggleTask,
  WidgetActions.newTask,
  WidgetActions.newNote,
};

/// Destinations for actions whose navigation matters; the rest land on `/`
/// (the warm click stream opens sheets / performs the real navigation).
const Map<String, String> _widgetActionRoutes = {
  WidgetActions.openDashboard: '/dashboard',
};

/// Notes navigation must work without HomeScreen being mounted. Accept the
/// legacy `uuid` key too, since launchers may retain an older PendingIntent.
String? widgetNotesLocation(Uri uri) {
  if (uri.scheme.isNotEmpty &&
      (uri.scheme != 'todoaw' || uri.host != 'widget')) {
    return null;
  }
  if (uri.pathSegments.isEmpty) return null;
  final action = uri.pathSegments.first;
  if (action == WidgetActions.openNotes) return '/notes';
  if (action != WidgetActions.openNote) return null;
  final id = uri.queryParameters['note_uuid'] ?? uri.queryParameters['uuid'];
  return id == null || id.isEmpty
      ? '/notes'
      : '/notes/${Uri.encodeComponent(id)}';
}

/// Warm widget clicks use the router directly for notes, rather than leaving
/// a pending action that could be replayed the next time HomeScreen mounts.
void handleWidgetClick(Uri? uri, {required void Function(String) navigate}) {
  if (uri == null) return;
  final location = widgetNotesLocation(uri);
  if (location != null) {
    navigate(location);
  } else {
    applyWidgetUri(uri);
  }
}

/// GoRouter redirect guard: the Flutter engine feeds widget intent URIs into
/// the router (cold start initial route = full `todoaw://widget/...`, warm
/// `pushRouteInformation` = path-only `/toggle_task?...`). Full-form URIs only
/// occur on cold start. Notes go directly to their own routes; other actions
/// are applied here (the warm click stream covers path-only pushes).
/// Path-only pushes are mapped to their real route so the
/// engine can never render the "Page Not Found" error — which would unmount
/// HomeScreen and kill widget action handling. Both the redirect and the
/// click stream converge on the same destination, so delivery order does not
/// matter.
String? widgetRedirect(Uri uri) {
  final notesLocation = widgetNotesLocation(uri);
  if (notesLocation != null) return notesLocation;
  if (uri.scheme == 'todoaw' && uri.host == 'widget') {
    applyWidgetUri(uri);
    return '/';
  }
  if (uri.scheme.isEmpty &&
      uri.pathSegments.isNotEmpty &&
      _widgetActionNames.contains(uri.pathSegments.first)) {
    return _widgetActionRoutes[uri.pathSegments.first] ?? '/';
  }
  return null;
}
