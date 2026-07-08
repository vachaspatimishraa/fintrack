import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/calendar_analytics_data.dart';
import '../../domain/repositories/calendar_analytics_repository.dart';

class CalendarController {
  final CalendarAnalyticsRepository _repository;
  final Ref ref;

  CalendarController(this._repository, this.ref);

  DateTime previousMonth(DateTime month) {
    return DateTime(month.year, month.month - 1, 1);
  }

  DateTime nextMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 1);
  }

  DateTime todayMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  CalendarDayData? selectedDay(
    CalendarAnalyticsReport report,
    DateTime date,
  ) {
    for (final day in report.days) {
      if (day.date.year == date.year &&
          day.date.month == date.month &&
          day.date.day == date.day) {
        return day;
      }
    }
    return null;
  }

  List<String> insights(CalendarAnalyticsReport report) {
    return report.insights;
  }

  String activityLabel(CalendarActivityLevel level) {
    switch (level) {
      case CalendarActivityLevel.none:
        return 'None';
      case CalendarActivityLevel.veryLow:
        return 'Very Low';
      case CalendarActivityLevel.low:
        return 'Low';
      case CalendarActivityLevel.medium:
        return 'Medium';
      case CalendarActivityLevel.high:
        return 'High';
      case CalendarActivityLevel.veryHigh:
        return 'Very High';
    }
  }

  bool isOfflineMode() => false;

  CalendarAnalyticsRepository get repository => _repository;
}
