import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/providers/category_provider.dart';
import 'package:todoaw/providers/task_list_provider.dart';
import 'package:todoaw/data/repositories/category_repository.dart';
import 'package:todoaw/data/repositories/task_repository.dart';
import 'package:todoaw/presentation/screens/task_form_screen.dart'
    show TaskFormSheet;
import 'package:todoaw/core/l10n/strings.dart';
import 'package:todoaw/core/design/light_theme.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

Widget createTestApp({
  required TaskRepository taskRepo,
  required CategoryRepository categoryRepo,
  String? taskId,
}) {
  final task = taskId != null
      ? Task(
          uuid: taskId,
          title: 'Existing Task',
          description: 'Description',
          priority: Priority.p1,
          createdAt: DateTime(2026, 7, 20),
          updatedAt: DateTime(2026, 7, 20),
        )
      : null;

  if (taskId != null && task != null) {
    when(() => taskRepo.getById(taskId)).thenAnswer((_) async => task);
  }

  return MaterialApp(
    theme: LightTheme.theme,
    home: ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(taskRepo),
        categoryRepositoryProvider.overrideWithValue(categoryRepo),
      ],
      child: Scaffold(
        body: TaskFormSheet(taskId: taskId),
      ),
    ),
  );
}

void main() {
  late MockTaskRepository taskRepo;
  late MockCategoryRepository categoryRepo;

  setUpAll(() {
    registerFallbackValue(Task(
      uuid: 'fallback',
      title: '',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    ));
    registerFallbackValue(Priority.p3);
  });

  setUp(() {
    taskRepo = MockTaskRepository();
    categoryRepo = MockCategoryRepository();
  });

  group('TaskFormSheet', () {
    testWidgets('shows create form with empty fields', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text(S.taskBaru), findsOneWidget);
      expect(find.text(S.simpan), findsOneWidget);
    });

    testWidgets('shows save button when title is empty', (tester) async {
      when(() => taskRepo.getActive()).thenAnswer((_) async => []);
      when(() => categoryRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        taskRepo: taskRepo,
        categoryRepo: categoryRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text(S.simpan), findsOneWidget);
    });
  });
}
