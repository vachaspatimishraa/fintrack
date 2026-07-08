import '../entities/calendar_analytics_data.dart';

class HeatmapCalculator {
  const HeatmapCalculator._();

  static double normalize({
    required double income,
    required double expense,
    required int transactionCount,
    required double maxRawValue,
  }) {
    final raw = rawValue(
      income: income,
      expense: expense,
      transactionCount: transactionCount,
    );
    if (maxRawValue <= 0) return 0;
    return (raw / maxRawValue * 100).clamp(0, 100).toDouble();
  }

  static double rawValue({
    required double income,
    required double expense,
    required int transactionCount,
  }) {
    return income.abs() + expense.abs() + (transactionCount * 100);
  }

  static CalendarActivityLevel activityLevel(double heatmapValue) {
    if (heatmapValue <= 0) return CalendarActivityLevel.none;
    if (heatmapValue <= 20) return CalendarActivityLevel.veryLow;
    if (heatmapValue <= 40) return CalendarActivityLevel.low;
    if (heatmapValue <= 60) return CalendarActivityLevel.medium;
    if (heatmapValue <= 80) return CalendarActivityLevel.high;
    return CalendarActivityLevel.veryHigh;
  }
}
