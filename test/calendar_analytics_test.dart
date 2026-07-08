import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/entities/calendar_analytics_data.dart';
import 'package:fintrack/features/analytics/domain/utils/activity_streak_service.dart';
import 'package:fintrack/features/analytics/domain/utils/calendar_analytics_engine.dart';
import 'package:fintrack/features/analytics/domain/utils/heatmap_calculator.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('HeatmapCalculator', () {
    test('normalizes heatmap formula and activity level', () {
      final value = HeatmapCalculator.normalize(
        income: 500,
        expense: 400,
        transactionCount: 1,
        maxRawValue: 1000,
      );

      expect(value, 100);
      expect(
        HeatmapCalculator.activityLevel(value),
        CalendarActivityLevel.veryHigh,
      );
      expect(
        HeatmapCalculator.activityLevel(0),
        CalendarActivityLevel.none,
      );
    });
  });

  group('CalendarAnalyticsEngine', () {
    test('aggregates daily and monthly calendar analytics', () {
      final month = DateTime(2026, 7, 1);
      final transactions = [
        _tx('1', 'income', 50000, DateTime(2026, 7, 1, 9), 'Salary'),
        _tx('2', 'expense', 120, DateTime(2026, 7, 1, 10), 'Food'),
        _tx('3', 'expense', 750, DateTime(2026, 7, 2, 20), 'Food'),
        _tx('4', 'expense', 2500, DateTime(2026, 8, 1, 12), 'Shopping'),
      ];

      final report = CalendarAnalyticsEngine.aggregate(
        transactions: transactions,
        visibleMonth: month,
      );

      expect(report.days.length, 31);
      expect(report.monthSummary.totalIncome, 50000);
      expect(report.monthSummary.totalExpense, 870);
      expect(report.monthSummary.transactionCount, 3);
      expect(report.monthSummary.highestSpendingDay?.date.day, 2);
      expect(report.isEmpty, false);
    });

    test('calculates day summary and chronological timeline', () {
      final date = DateTime(2026, 7, 18);
      final transactions = [
        _tx('2', 'expense', 750, DateTime(2026, 7, 18, 19, 45), 'Food'),
        _tx('1', 'expense', 120, DateTime(2026, 7, 18, 8), 'Food'),
        _tx('3', 'income', 50000, DateTime(2026, 7, 18, 11, 30), 'Salary'),
      ];

      final summary = CalendarAnalyticsEngine.getDaySummary(
        transactions: transactions,
        date: date,
      );
      final timeline = CalendarAnalyticsEngine.getDailyTransactions(
        transactions: transactions,
        date: date,
      );

      expect(summary.income, 50000);
      expect(summary.expense, 870);
      expect(summary.transactionCount, 3);
      expect(timeline.first.amount, 120);
      expect(timeline.last.amount, 750);
    });

    test('calculates week month and year summaries', () {
      final transactions = [
        _tx('1', 'expense', 100, DateTime(2026, 1, 2), 'Food'),
        _tx('2', 'income', 1000, DateTime(2026, 7, 2), 'Salary'),
      ];

      expect(
        CalendarAnalyticsEngine.getWeekSummary(
          transactions: transactions,
          date: DateTime(2026, 7, 2),
        ).totalIncome,
        1000,
      );
      expect(
        CalendarAnalyticsEngine.getMonthSummary(
          transactions: transactions,
          month: DateTime(2026, 7, 1),
        ).incomeDays,
        1,
      );
      expect(
        CalendarAnalyticsEngine.getYearSummary(
          transactions: transactions,
          year: 2026,
        ).transactionCount,
        2,
      );
    });
  });

  group('ActivityStreakService', () {
    test('calculates current and longest activity streaks', () {
      final days = [
        _day(DateTime(2026, 7, 1), 1, 10),
        _day(DateTime(2026, 7, 2), 1, 10),
        _day(DateTime(2026, 7, 3), 0, 0),
        _day(DateTime(2026, 7, 4), 1, 10),
      ];

      final streak = ActivityStreakService.calculate(days);

      expect(streak.longestActivityStreak, 2);
      expect(streak.currentActivityStreak, 1);
      expect(streak.longestSavingsStreak, 2);
    });
  });
}

TransactionEntity _tx(
  String id,
  String type,
  double amount,
  DateTime date,
  String category,
) {
  return TransactionEntity(
    id: id,
    type: type,
    amount: amount,
    category: category,
    title: category,
    date: date,
  );
}

CalendarDayData _day(DateTime date, int count, double savings) {
  return CalendarDayData(
    date: date,
    income: savings > 0 ? savings : 0,
    expense: 0,
    savings: savings,
    cashFlow: savings,
    transactionCount: count,
    heatmapValue: count > 0 ? 50 : 0,
    activityLevel:
        count > 0 ? CalendarActivityLevel.medium : CalendarActivityLevel.none,
    largestExpense: 0,
    largestIncome: savings,
    averageTransaction: savings,
    categoryDistribution: const {},
  );
}
