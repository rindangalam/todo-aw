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
