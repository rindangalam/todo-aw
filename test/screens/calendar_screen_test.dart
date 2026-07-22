import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/core/l10n/strings.dart';
import 'package:todoaw/core/theme.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/providers/task_list_provider.dart';
import 'package:todoaw/providers/category_provider.dart';
import 'package:todoaw/data/repositories/task_repository.dart';
import 'package:todoaw/data/repositories/category_repository.dart';
import 'package:todoaw/presentation/screens/calendar_screen.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

Widget createTestApp({
  required TaskRepository taskRepo,
  required CategoryRepository categoryRepo,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(taskRepo),
        categoryRepositoryProvider.overrideWithValue(categoryRepo),
      ],
      child: const CalendarScreen(),
    ),
  );
}

void main() {
  late MockTaskRepository taskRepo;
  late MockCategoryRepository categoryRepo;

  setUp(() {
    taskRepo = MockTaskRepository();
    categoryRepo = MockCategoryRepository();
  });

  group('CalendarScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows month header and navigation', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows day headers in Indonesian', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sen'), findsOneWidget);
      expect(find.text('Sel'), findsOneWidget);
      expect(find.text('Rab'), findsOneWidget);
      expect(find.text('Kam'), findsOneWidget);
      expect(find.text('Jum'), findsOneWidget);
      expect(find.text('Sab'), findsOneWidget);
      expect(find.text('Min'), findsOneWidget);
    });

    testWidgets('shows no tasks message for empty day', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text(S.kalenderTidakAdaTugas), findsOneWidget);
    });

    testWidgets('shows task in daily list when date matches', (tester) async {
      final now = DateTime.now();
      when(() => taskRepo.getActive()).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Meeting',
              dueDate: DateTime(now.year, now.month, now.day),
              createdAt: now,
              updatedAt: now,
            ),
          ]);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Meeting'), findsOneWidget);
    });

    testWidgets('shows error state', (tester) async {
      when(() => taskRepo.getActive()).thenThrow(Exception('DB error'));
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining(S.error), findsOneWidget);
    });
  });
}
