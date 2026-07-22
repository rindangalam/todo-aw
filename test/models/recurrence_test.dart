import 'package:flutter_test/flutter_test.dart';
import 'package:todoaw/data/models/recurrence.dart';

void main() {
  group('RecurrenceRule.toRrule', () {
    test('daily', () {
      const rule = RecurrenceRule(frequency: RecurrenceFrequency.daily);
      expect(rule.toRrule(), 'FREQ=DAILY;INTERVAL=1');
    });

    test('daily with interval', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 3,
      );
      expect(rule.toRrule(), 'FREQ=DAILY;INTERVAL=3');
    });

    test('weekday', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekday,
      );
      expect(rule.toRrule(), 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR');
    });

    test('weekly without byDay', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
      );
      expect(rule.toRrule(), 'FREQ=WEEKLY;INTERVAL=1');
    });

    test('weekly with byDay', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        byDay: [1, 3, 5],
      );
      expect(rule.toRrule(), 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR');
    });

    test('monthly with byMonthDay', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        byMonthDay: 15,
      );
      expect(rule.toRrule(), 'FREQ=MONTHLY;BYMONTHDAY=15');
    });

    test('yearly', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.yearly,
      );
      expect(rule.toRrule(), 'FREQ=YEARLY');
    });

    test('custom returns empty string', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.custom,
      );
      expect(rule.toRrule(), '');
    });
  });

  group('RecurrenceRule.fromRrule', () {
    test('returns null for null input', () {
      expect(RecurrenceRule.fromRrule(null), null);
    });

    test('returns null for empty string', () {
      expect(RecurrenceRule.fromRrule(''), null);
    });

    test('parses daily', () {
      final rule = RecurrenceRule.fromRrule('FREQ=DAILY;INTERVAL=2');
      expect(rule!.frequency, RecurrenceFrequency.daily);
      expect(rule.interval, 2);
    });

    test('parses weekday as weekly with byday', () {
      final rule = RecurrenceRule.fromRrule('FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR');
      expect(rule!.frequency, RecurrenceFrequency.weekly);
      expect(rule.byDay, [1, 2, 3, 4, 5]);
    });

    test('parses weekly with byday', () {
      final rule =
          RecurrenceRule.fromRrule('FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR');
      expect(rule!.frequency, RecurrenceFrequency.weekly);
      expect(rule.byDay, [1, 3, 5]);
      expect(rule.interval, 1);
    });

    test('parses monthly', () {
      final rule = RecurrenceRule.fromRrule('FREQ=MONTHLY;BYMONTHDAY=15');
      expect(rule!.frequency, RecurrenceFrequency.monthly);
      expect(rule.byMonthDay, 15);
    });

    test('parses yearly', () {
      final rule = RecurrenceRule.fromRrule('FREQ=YEARLY');
      expect(rule!.frequency, RecurrenceFrequency.yearly);
    });
  });

  group('RecurrenceRule round-trip', () {
    test('daily preserves frequency', () {
      const original = RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 3,
      );
      final restored = RecurrenceRule.fromRrule(original.toRrule());
      expect(restored!.frequency, original.frequency);
      expect(restored.interval, original.interval);
    });

    test('weekly with days preserves byDay', () {
      const original = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        byDay: [1, 3, 5],
      );
      final restored = RecurrenceRule.fromRrule(original.toRrule());
      expect(restored!.frequency, original.frequency);
      expect(restored.byDay, [1, 3, 5]);
    });

    test('monthly preserves byMonthDay', () {
      const original = RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        byMonthDay: 15,
      );
      final restored = RecurrenceRule.fromRrule(original.toRrule());
      expect(restored!.frequency, original.frequency);
      expect(restored.byMonthDay, 15);
    });
  });

  group('RecurrenceRule.displayText', () {
    test('daily with interval 1', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
      );
      expect(rule.displayText(), 'Setiap hari');
    });

    test('daily with interval 3', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 3,
      );
      expect(rule.displayText(), 'Setiap 3 hari');
    });

    test('weekday', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekday,
      );
      expect(rule.displayText(), 'Setiap hari kerja');
    });

    test('weekly default', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
      );
      expect(rule.displayText(), 'Setiap minggu');
    });

    test('yearly', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.yearly,
      );
      expect(rule.displayText(), 'Setiap tahun');
    });
  });
}
