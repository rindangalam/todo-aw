import 'package:workmanager/workmanager.dart';

import '../data/database.dart';
import 'widget_bridge.dart';

const String kWidgetRefreshTask = 'todoaw.widget.refresh';

/// Periodic refresh so widgets stay fresh while the app is not used.
/// Registered once from main() (guarded by `widget_worker_registered`).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task != kWidgetRefreshTask) return true;
    try {
      await AppDatabase.init();
      await refreshWidgetsFromPrefs();
      return true;
    } catch (_) {
      return false;
    }
  });
}
