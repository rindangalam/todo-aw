import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/providers/category_provider.dart';
import 'package:todoaw/providers/task_list_provider.dart';
import 'package:todoaw/data/repositories/category_repository.dart';
import 'package:todoaw/data/repositories/task_repository.dart';
import 'package:todoaw/presentation/screens/home_screen.dart';
import 'package:todoaw/core/l10n/strings.dart';
import 'package:todoaw/core/theme.dart';

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
      child: const HomeScreen(),
    ),
  );
}

void main() {
  late MockTaskRepository taskRepo;
  late MockCategoryRepository categoryRepo;
  late DateTime now;

  setUp(() async {
    taskRepo = MockTaskRepository();
    categoryRepo = MockCategoryRepository();
    now = DateTime(2026, 7, 20);
    await initializeDateFormatting();
  });

  group('HomeScreen', () {
    testWidgets('shows empty state when no tasks', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text(S.homeTidakAdaTugas), findsOneWidget);
      expect(find.text(S.homeBuatTugasPertama), findsOneWidget);
    });

    testWidgets('shows task list', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Buy groceries',
              description: 'Milk and eggs',
              priority: Priority.p1,
              dueDate: DateTime(2026, 7, 20),
              createdAt: now,
              updatedAt: now,
            ),
            Task(
              uuid: '2',
              title: 'Walk dog',
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

      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Walk dog'), findsOneWidget);
    });

    testWidgets('shows filter bar', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text(S.filterTitle), findsOneWidget);
    });
  });
}
