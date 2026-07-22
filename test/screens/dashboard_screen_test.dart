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
import 'package:todoaw/presentation/screens/dashboard_screen.dart';

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
      child: const DashboardScreen(),
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

  group('DashboardScreen', () {
    testWidgets('shows today progress card', (tester) async {
      final now = DateTime.now();
      when(() => taskRepo.getActive()).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Test',
              dueDate: DateTime(now.year, now.month, now.day),
              createdAt: now,
              updatedAt: now,
            ),
          ]);
      when(() => taskRepo.getAll()).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Test',
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

      expect(find.text(S.dashboardProgressHariIni), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('shows stat cards', (tester) async {
      final now = DateTime.now();
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => taskRepo.getAll()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets);
      expect(find.text(S.dashboardTotalAktif), findsOneWidget);
      expect(find.text(S.dashboardTotalSelesai), findsOneWidget);
    });

    testWidgets('shows weekly chart section', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => taskRepo.getAll()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text(S.dashboardProduktivitas), findsOneWidget);
      expect(find.text(S.dashboardTargetMingguan), findsOneWidget);
    });

    testWidgets('shows streak section when data exists', (tester) async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      when(() => taskRepo.getActive()).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Done',
              isCompleted: true,
              updatedAt: yesterday,
              createdAt: yesterday,
            ),
          ]);
      when(() => taskRepo.getAll()).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Done',
              isCompleted: true,
              updatedAt: yesterday,
              createdAt: yesterday,
            ),
          ]);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });
  });
}
