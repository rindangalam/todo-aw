enum RecurrenceFrequency { daily, weekday, weekly, monthly, yearly, custom }

class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int interval;
  final List<int> byDay; // 0=Sun, 1=Mon ... 6=Sat
  final int? byMonthDay;

  const RecurrenceRule({
    this.frequency = RecurrenceFrequency.weekly,
    this.interval = 1,
    this.byDay = const [],
    this.byMonthDay,
  });

  String toRrule() {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'FREQ=DAILY;INTERVAL=$interval';
      case RecurrenceFrequency.weekday:
        return 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR';
      case RecurrenceFrequency.weekly:
        if (byDay.isEmpty) return 'FREQ=WEEKLY;INTERVAL=$interval';
        final days = byDay.map(_dayToStr).join(',');
        return 'FREQ=WEEKLY;INTERVAL=$interval;BYDAY=$days';
      case RecurrenceFrequency.monthly:
        if (byMonthDay != null) {
          return 'FREQ=MONTHLY;BYMONTHDAY=$byMonthDay';
        }
        return 'FREQ=MONTHLY;INTERVAL=$interval';
      case RecurrenceFrequency.yearly:
        return 'FREQ=YEARLY';
      case RecurrenceFrequency.custom:
        return '';
    }
  }

  static RecurrenceRule? fromRrule(String? rrule) {
    if (rrule == null || rrule.isEmpty) return null;
    final parts = rrule.split(';');
    RecurrenceFrequency freq = RecurrenceFrequency.daily;
    int interval = 1;
    List<int> byDay = [];
    int? byMonthDay;

    for (final part in parts) {
      final kv = part.split('=');
      if (kv.length != 2) continue;
      switch (kv[0]) {
        case 'FREQ':
          switch (kv[1]) {
            case 'DAILY':
              freq = RecurrenceFrequency.daily;
              break;
            case 'WEEKLY':
              freq = RecurrenceFrequency.weekly;
              break;
            case 'MONTHLY':
              freq = RecurrenceFrequency.monthly;
              break;
            case 'YEARLY':
              freq = RecurrenceFrequency.yearly;
              break;
          }
          break;
        case 'INTERVAL':
          interval = int.tryParse(kv[1]) ?? 1;
          break;
        case 'BYDAY':
          byDay = kv[1].split(',').map(_dayToInt).toList();
          break;
        case 'BYMONTHDAY':
          byMonthDay = int.tryParse(kv[1]);
          break;
      }
    }
    return RecurrenceRule(
      frequency: freq,
      interval: interval,
      byDay: byDay,
      byMonthDay: byMonthDay,
    );
  }

  String displayText() {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return interval == 1 ? 'Setiap hari' : 'Setiap $interval hari';
      case RecurrenceFrequency.weekday:
        return 'Setiap hari kerja';
      case RecurrenceFrequency.weekly:
        if (byDay.isEmpty) {
          return interval == 1 ? 'Setiap minggu' : 'Setiap $interval minggu';
        }
        final days = byDay.map((d) {
          switch (d) {
            case 0:
              return 'Min';
            case 1:
              return 'Sen';
            case 2:
              return 'Sel';
            case 3:
              return 'Rab';
            case 4:
              return 'Kam';
            case 5:
              return 'Jum';
            case 6:
              return 'Sab';
            default:
              return '';
          }
        }).join(', ');
        return 'Mingguan ($days)';
      case RecurrenceFrequency.monthly:
        return byMonthDay != null
            ? 'Bulanan (tgl $byMonthDay)'
            : 'Setiap $interval bulan';
      case RecurrenceFrequency.yearly:
        return 'Setiap tahun';
      case RecurrenceFrequency.custom:
        return 'Kustom';
    }
  }

  static String _dayToStr(int day) {
    const days = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
    return days[day.clamp(0, 6)];
  }

  static int _dayToInt(String s) {
    switch (s) {
      case 'SU':
        return 0;
      case 'MO':
        return 1;
      case 'TU':
        return 2;
      case 'WE':
        return 3;
      case 'TH':
        return 4;
      case 'FR':
        return 5;
      case 'SA':
        return 6;
      default:
        return 0;
    }
  }
}
