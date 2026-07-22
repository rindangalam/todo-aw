import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todoaw/core/l10n/strings.dart';
import 'package:todoaw/core/theme.dart';
import 'package:todoaw/data/models/habit.dart';
import 'package:todoaw/providers/habit_provider.dart';
import 'package:todoaw/data/repositories/habit_repository.dart';
import 'package:todoaw/presentation/screens/habits_screen.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

Widget createTestApp({
  required HabitRepository habitRepo,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: ProviderScope(
      overrides: [
        habitRepositoryProvider.overrideWithValue(habitRepo),
      ],
      child: const HabitsScreen(),
    ),
  );
}

void main() {
  late MockHabitRepository habitRepo;

  setUp(() {
    habitRepo = MockHabitRepository();
  });

  group('HabitsScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      when(() => habitRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(habitRepo: habitRepo));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no habits', (tester) async {
      when(() => habitRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(habitRepo: habitRepo));
      await tester.pumpAndSettle();

      expect(find.text(S.habitKosong), findsOneWidget);
      expect(find.text(S.habitBuatPertama), findsOneWidget);
    });

    testWidgets('shows habit list', (tester) async {
      final now = DateTime.now();
      when(() => habitRepo.getAll()).thenAnswer((_) async => [
            Habit(
              uuid: '1',
              name: 'Minum Air',
              createdAt: now,
              updatedAt: now,
            ),
            Habit(
              uuid: '2',
              name: 'Olahraga',
              createdAt: now,
              updatedAt: now,
            ),
          ]);

      await tester.pumpWidget(createTestApp(habitRepo: habitRepo));
      await tester.pumpAndSettle();

      expect(find.text('Minum Air'), findsOneWidget);
      expect(find.text('Olahraga'), findsOneWidget);
    });

    testWidgets('shows FAB to add habit', (tester) async {
      when(() => habitRepo.getAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(habitRepo: habitRepo));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
