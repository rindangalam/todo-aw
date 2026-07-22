import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/providers/task_list_provider.dart';
import 'package:todoaw/providers/category_provider.dart';
import 'package:todoaw/data/repositories/task_repository.dart';
import 'package:todoaw/data/repositories/category_repository.dart';
import 'package:todoaw/presentation/screens/search_screen.dart';
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
      child: const SearchScreen(),
    ),
  );
}

void main() {
  late MockTaskRepository taskRepo;
  late MockCategoryRepository categoryRepo;
  late DateTime now;

  setUp(() {
    taskRepo = MockTaskRepository();
    categoryRepo = MockCategoryRepository();
    now = DateTime(2026, 7, 20);
  });

  group('SearchScreen', () {
    testWidgets('shows search field with hint', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text(S.searchHint), findsOneWidget);
    });

    testWidgets('shows empty state when query is empty', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text(S.searchKetik), findsOneWidget);
    });

    testWidgets('shows search results for matching query', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Buy groceries',
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
      when(() => taskRepo.search('groceries')).thenAnswer((_) async => [
            Task(
              uuid: '1',
              title: 'Buy groceries',
              createdAt: now,
              updatedAt: now,
            ),
          ]);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'groceries');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Walk dog'), findsNothing);
    });

    testWidgets('shows no results message for unmatched query', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => taskRepo.search('zzzzz')).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.textContaining(S.searchTidakDitemukan), findsOneWidget);
    });

    testWidgets('shows clear button when text is entered', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => taskRepo.search('test')).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
}
