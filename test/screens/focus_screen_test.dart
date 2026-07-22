import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/core/l10n/strings.dart';
import 'package:todoaw/core/theme.dart';
import 'package:todoaw/data/repositories/focus_repository.dart';
import 'package:todoaw/data/repositories/task_repository.dart';
import 'package:todoaw/providers/focus_provider.dart';
import 'package:todoaw/providers/task_list_provider.dart';
import 'package:todoaw/presentation/screens/focus_screen.dart';

class MockFocusRepository extends Mock implements FocusRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

Widget createTestApp({
  required FocusRepository focusRepo,
  required TaskRepository taskRepo,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: ProviderScope(
      overrides: [
        focusRepositoryProvider.overrideWithValue(focusRepo),
        taskRepositoryProvider.overrideWithValue(taskRepo),
      ],
      child: const FocusScreen(),
    ),
  );
}

void main() {
  late MockFocusRepository focusRepo;
  late MockTaskRepository taskRepo;

  setUp(() {
    focusRepo = MockFocusRepository();
    taskRepo = MockTaskRepository();
  });

  group('FocusScreen', () {
    testWidgets('shows timer display', (tester) async {
      when(() => focusRepo.getAll()).thenAnswer((_) async => []);
      when(() => focusRepo.getTodayTotalMinutes())
          .thenAnswer((_) async => 0);
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        focusRepo: focusRepo,
        taskRepo: taskRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text('25:00'), findsOneWidget);
      expect(find.text(S.focusMulai), findsOneWidget);
    });

    testWidgets('shows duration chips', (tester) async {
      when(() => focusRepo.getAll()).thenAnswer((_) async => []);
      when(() => focusRepo.getTodayTotalMinutes())
          .thenAnswer((_) async => 0);
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        focusRepo: focusRepo,
        taskRepo: taskRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text('25'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('shows today minutes', (tester) async {
      when(() => focusRepo.getAll()).thenAnswer((_) async => []);
      when(() => focusRepo.getTodayTotalMinutes())
          .thenAnswer((_) async => 30);
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        focusRepo: focusRepo,
        taskRepo: taskRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('30'), findsWidgets);
    });
  });
}
