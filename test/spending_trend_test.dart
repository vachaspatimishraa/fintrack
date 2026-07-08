import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/entities/spending_trend_data.dart';
import 'package:fintrack/features/analytics/domain/utils/momentum_calculator.dart';
import 'package:fintrack/features/analytics/domain/utils/moving_average_calculator.dart';
import 'package:fintrack/features/analytics/domain/utils/trend_comparison_service.dart';
import 'package:fintrack/features/analytics/domain/utils/trend_engine.dart';
import 'package:fintrack/features/analytics/domain/utils/velocity_calculator.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('TrendComparisonService', () {
    test('calculates growth percentage', () {
      expect(TrendComparisonService.growthPercentage(150, 100), 50);
      expect(TrendComparisonService.growthPercentage(50, 100), -50);
      expect(TrendComparisonService.growthPercentage(100, 0), 100);
      expect(TrendComparisonService.growthPercentage(0, 0), 0);
    });

    test('classifies trend direction', () {
      expect(
        TrendComparisonService.directionFor(8),
        TrendDirection.increasing,
      );
      expect(
        TrendComparisonService.directionFor(-8),
        TrendDirection.declining,
      );
      expect(
        TrendComparisonService.directionFor(2),
        TrendDirection.stable,
      );
    });
  });

  group('MovingAverageCalculator', () {
    test('calculates rolling average', () {
      final result = MovingAverageCalculator.calculate(
        [10, 20, 30, 40],
        window: 3,
      );
      expect(result, [10, 15, 20, 30]);
    });
  });

  group('VelocityCalculator', () {
    test('calculates spending velocity', () {
      expect(VelocityCalculator.calculate(180, 100), 80);
      expect(VelocityCalculator.describe(-10), 'Decreasing');
    });
  });

  group('MomentumCalculator', () {
    test('calculates acceleration from recent velocities', () {
      expect(MomentumCalculator.calculate([100, 130, 190]), 30);
      expect(MomentumCalculator.calculate([100, 130]), 0);
    });
  });

  group('TrendEngine', () {
    test('aggregates daily spending trend and forecast', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final transactions = [
        _tx('1', 100, today.subtract(const Duration(days: 2))),
        _tx('2', 150, today.subtract(const Duration(days: 1))),
        _tx('3', 250, today),
        _tx('4', 800, today, type: 'income'),
      ];

      final report = TrendEngine.aggregate(
        transactions: transactions,
        timeFilter: 'month',
      );

      expect(report.isEmpty, false);
      expect(report.totalSpending, 500);
      expect(report.transactionCount, 3);
      expect(report.points.length, 3);
      expect(report.points.last.amount, 250);
      expect(report.forecast.expectedSpending, greaterThanOrEqualTo(0));
      expect(report.peakPeriods.first.amount, 250);
    });

    test('supports weekly, monthly and yearly trend helpers', () {
      final now = DateTime.now();
      final transactions = [
        _tx('1', 100, now.subtract(const Duration(days: 20))),
        _tx('2', 200, now.subtract(const Duration(days: 10))),
        _tx('3', 300, now),
      ];

      expect(TrendEngine.getDailyTrend(transactions).granularity,
          TrendGranularity.daily);
      expect(TrendEngine.getWeeklyTrend(transactions).granularity,
          TrendGranularity.weekly);
      expect(TrendEngine.getMonthlyTrend(transactions).granularity,
          TrendGranularity.monthly);
      expect(TrendEngine.getYearlyTrend(transactions).granularity,
          TrendGranularity.yearly);
    });
  });
}

TransactionEntity _tx(
  String id,
  double amount,
  DateTime date, {
  String type = 'expense',
}) {
  return TransactionEntity(
    id: id,
    type: type,
    amount: amount,
    category: type == 'expense' ? 'Food' : 'Salary',
    title: 'Sample',
    date: date,
  );
}
