import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/focus_session.dart';
import '../data/repositories/focus_repository.dart';
import '../domain/services/notification_service.dart';

final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  return FocusRepository();
});

final focusSessionsProvider =
    FutureProvider<List<FocusSession>>((ref) async {
  return ref.read(focusRepositoryProvider).getAll();
});

final focusTodayMinutesProvider = FutureProvider<int>((ref) async {
  return ref.read(focusRepositoryProvider).getTodayTotalMinutes();
});

final focusSessionProvider =
    StateNotifierProvider<FocusSessionNotifier, FocusState>((ref) {
  return FocusSessionNotifier(ref.read(focusRepositoryProvider), ref);
});

class FocusState {
  final bool isRunning;
  final bool isPaused;
  final int durationMinutes;
  final int remainingSeconds;
  final String? currentSessionId;
  final String? taskId;

  const FocusState({
    this.isRunning = false,
    this.isPaused = false,
    this.durationMinutes = 25,
    this.remainingSeconds = 25 * 60,
    this.currentSessionId,
    this.taskId,
  });

  FocusState copyWith({
    bool? isRunning,
    bool? isPaused,
    int? durationMinutes,
    int? remainingSeconds,
    String? currentSessionId,
    String? taskId,
  }) {
    return FocusState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      taskId: taskId ?? this.taskId,
    );
  }
}

class FocusSessionNotifier extends StateNotifier<FocusState> {
  final FocusRepository _repository;
  final Ref _ref;
  Timer? _timer;

  FocusSessionNotifier(this._repository, this._ref)
      : super(const FocusState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setDuration(int minutes) {
    if (!state.isRunning) {
      state = state.copyWith(
        durationMinutes: minutes,
        remainingSeconds: minutes * 60,
      );
    }
  }

  Future<void> start({String? taskId}) async {
    if (state.isRunning) return;

    final session = await _repository.create(
      taskId: taskId,
      durationMinutes: state.durationMinutes,
    );

    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      currentSessionId: session.uuid,
      taskId: taskId,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _completeSession();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void pause() {
    if (!state.isRunning || state.isPaused) return;
    _timer?.cancel();
    state = state.copyWith(isPaused: true);
  }

  void resume() {
    if (!state.isRunning || !state.isPaused) return;
    state = state.copyWith(isPaused: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _completeSession();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  Future<void> stop() async {
    _timer?.cancel();
    if (state.currentSessionId != null) {
      await _repository.cancel(state.currentSessionId!);
    }
    state = const FocusState();
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    if (state.currentSessionId != null) {
      await _repository.complete(state.currentSessionId!);
    }
    HapticFeedback.heavyImpact();
    NotificationService.showImmediate(
      title: 'Sesi Fokus Selesai',
      body: '${state.durationMinutes} menit — Mantap!',
    );
    state = const FocusState();
    _ref.invalidate(focusSessionsProvider);
    _ref.invalidate(focusTodayMinutesProvider);
  }
}
