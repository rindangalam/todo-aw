import 'package:uuid/uuid.dart';

import '../database.dart';
import '../models/focus_session.dart';

class FocusRepository {
  final _uuid = const Uuid();

  Future<List<FocusSession>> getAll() => AppDatabase.getFocusSessions();

  Future<List<FocusSession>> getByTask(String taskId) =>
      AppDatabase.getFocusSessionsByTask(taskId);

  Future<int> getTodayTotalMinutes() async {
    final all = await AppDatabase.getFocusSessions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return all
        .where((s) =>
            s.isCompleted &&
            s.startedAt != null &&
            s.endedAt != null &&
            DateTime(s.startedAt!.year, s.startedAt!.month, s.startedAt!.day) ==
                today)
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  Future<FocusSession> create({
    String? taskId,
    int durationMinutes = 25,
  }) async {
    final now = DateTime.now();
    final session = FocusSession(
      uuid: _uuid.v4(),
      taskId: taskId,
      durationMinutes: durationMinutes,
      startedAt: now,
      createdAt: now,
    );
    await AppDatabase.insertFocusSession(session);
    return session;
  }

  Future<void> complete(String uuid) async {
    final sessions = await AppDatabase.getFocusSessions();
    final matches = sessions.where((s) => s.uuid == uuid).toList();
    final session = matches.isNotEmpty ? matches.first : null;
    if (session != null) {
      await AppDatabase.updateFocusSession(session.copyWith(
        isCompleted: true,
        endedAt: DateTime.now(),
      ));
    }
  }

  Future<void> cancel(String uuid) async {
    await AppDatabase.deleteFocusSession(uuid);
  }
}
