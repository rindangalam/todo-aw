import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/models/task.dart';
import 'package:todoaw/domain/services/recurring_task_service.dart';

void main() {
  late RecurringTaskService service;

  setUp(() {
    service = RecurringTaskService();
  });

  group('generateNext', () {
    test('returns null for non-recurring task', () {
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(service.generateNext(task), null);
    });

    test('returns null when recurringRule is null', () {
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(service.generateNext(task), null);
    });

    test('returns null for empty recurringRule (custom)', () {
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(service.generateNext(task), null);
    });

    test('daily generates next day', () {
      final now = DateTime.now();
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=DAILY;INTERVAL=1',
        isCompleted: true,
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(next!.isCompleted, false);
      expect(next.dueDate, now.add(const Duration(days: 1)));
      expect(next.uuid, '');
      expect(next.parentId, null);
      expect(next.deletedAt, null);
      expect(next.isArchived, false);
    });

    test('daily with interval 3 generates 3 days later', () {
      final now = DateTime.now();
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=DAILY;INTERVAL=3',
        isCompleted: true,
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(next!.dueDate, now.add(const Duration(days: 3)));
    });

    test('weekday skips Saturday', () {
      // 2026-07-20 is a Monday
      final friday = DateTime(2026, 7, 24);
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
        isCompleted: true,
        dueDate: friday,
        createdAt: friday,
        updatedAt: friday,
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(next!.dueDate!.weekday, DateTime.monday);
      expect(next.dueDate!.day, 27);
    });

    test('weekday skips Sunday', () {
      final friday = DateTime(2026, 7, 24);
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
        isCompleted: true,
        dueDate: friday,
        createdAt: friday,
        updatedAt: friday,
      );
      final next = service.generateNext(task);
      expect(next!.dueDate!.weekday, DateTime.monday);
    });

    test('weekly without byDay adds 7 days', () {
      final now = DateTime(2026, 7, 20); // Monday
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=WEEKLY;INTERVAL=1',
        isCompleted: true,
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(next!.dueDate, now.add(const Duration(days: 7)));
    });

    test('weekly with byDay picks next specified day', () {
      // Monday -> next occurrence of Wed (day 3) is 2 days later
      final monday = DateTime(2026, 7, 20);
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=WE,FR',
        isCompleted: true,
        dueDate: monday,
        createdAt: monday,
        updatedAt: monday,
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(next!.dueDate, monday.add(const Duration(days: 2)));
      expect(next.dueDate!.weekday, DateTime.wednesday);
    });

    test('weekly with byDay wraps around week', () {
      // Saturday -> next Mon (day 1) is 2 days later
      final saturday = DateTime(2026, 7, 25);
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR',
        isCompleted: true,
        dueDate: saturday,
        createdAt: saturday,
        updatedAt: saturday,
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(next!.dueDate!.weekday, DateTime.monday);
      expect(next.dueDate!.day, 27);
    });

    test('monthly with byMonthDay', () {
      final now = DateTime(2026, 7, 20);
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=MONTHLY;BYMONTHDAY=15',
        isCompleted: true,
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(next!.dueDate, DateTime(2026, 8, 15));
    });

    test('monthly without byMonthDay uses source day', () {
      final now = DateTime(2026, 1, 31);
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=MONTHLY;INTERVAL=1',
        isCompleted: true,
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(next!.dueDate, DateTime(2026, 2, 28));
    });

    test('monthly with interval', () {
      final now = DateTime(2026, 7, 20);
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=MONTHLY;INTERVAL=3',
        isCompleted: true,
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(next!.dueDate, DateTime(2026, 10, 20));
    });

    test('yearly', () {
      final now = DateTime(2026, 7, 20);
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=YEARLY',
        isCompleted: true,
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(next!.dueDate, DateTime(2027, 7, 20));
    });

    test('yearly on leap day returns Feb 28', () {
      final now = DateTime(2024, 2, 29);
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=YEARLY',
        isCompleted: true,
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(next!.dueDate, DateTime(2025, 2, 28));
    });

    test('custom (empty rrule) returns null', () {
      final now = DateTime.now();
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: '',
        isCompleted: true,
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final next = service.generateNext(task);
      expect(next, null);
    });

    test('uses dueDate when available', () {
      final now = DateTime(2026, 7, 20);
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=DAILY;INTERVAL=1',
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      final next = service.generateNext(task);
      expect(next!.dueDate, now.add(const Duration(days: 1)));
    });

    test('falls back to DateTime.now() when dueDate is null', () {
      final task = Task(
        uuid: 't1',
        title: 'Test',
        isRecurring: true,
        recurringRule: 'FREQ=DAILY;INTERVAL=1',
        isCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final next = service.generateNext(task);
      expect(next, isNotNull);
      expect(
          next!.dueDate!.isAfter(DateTime.now().subtract(
            const Duration(days: 1),
          )),
          true);
    });
  });
}
