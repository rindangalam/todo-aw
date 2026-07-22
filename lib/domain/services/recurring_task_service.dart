import '../../data/models/recurrence.dart';
import '../../data/models/task.dart';

class RecurringTaskService {
  DateTime? _nextDate(RecurrenceRule rule, DateTime from) {
    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        return from.add(Duration(days: rule.interval));
      case RecurrenceFrequency.weekday:
        var next = from.add(const Duration(days: 1));
        while (next.weekday == DateTime.saturday ||
            next.weekday == DateTime.sunday) {
          next = next.add(const Duration(days: 1));
        }
        return next;
      case RecurrenceFrequency.weekly:
        if (rule.byDay.isEmpty) {
          return from.add(Duration(days: 7 * rule.interval));
        }
        final currentWeekday = from.weekday % 7; // Mon=1..Sun=7 -> 1..0
        for (int i = 1; i <= 7; i++) {
          final nextWeekday = (currentWeekday + i) % 7;
          if (rule.byDay.contains(nextWeekday)) {
            return from.add(Duration(days: i));
          }
        }
        return from.add(const Duration(days: 7));
      case RecurrenceFrequency.monthly:
        final day = rule.byMonthDay ?? from.day;
        final totalMonths = from.month + rule.interval;
        final targetYear = from.year + (totalMonths - 1) ~/ 12;
        final targetMonth = ((totalMonths - 1) % 12) + 1;
        final daysInMonth = DateTime(targetYear, targetMonth + 1, 0).day;
        return DateTime(
            targetYear, targetMonth, day > daysInMonth ? daysInMonth : day);
      case RecurrenceFrequency.yearly:
        final daysInMonth = DateTime(from.year + 1, from.month + 1, 0).day;
        final clampedDay = from.day > daysInMonth ? daysInMonth : from.day;
        return DateTime(from.year + 1, from.month, clampedDay);
      case RecurrenceFrequency.custom:
        return null;
    }
  }

  Task? generateNext(Task completedTask) {
    if (!completedTask.isRecurring || completedTask.recurringRule == null) {
      return null;
    }
    final rule = RecurrenceRule.fromRrule(completedTask.recurringRule);
    if (rule == null) return null;

    final nextDate = _nextDate(rule, completedTask.dueDate ?? DateTime.now());
    if (nextDate == null) return null;

    return Task(
      uuid: '',
      title: completedTask.title,
      description: completedTask.description,
      isCompleted: false,
      priority: completedTask.priority,
      categoryId: completedTask.categoryId,
      dueDate: nextDate,
      isRecurring: completedTask.isRecurring,
      recurringRule: completedTask.recurringRule,
      parentId: null,
      isArchived: false,
      deletedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
