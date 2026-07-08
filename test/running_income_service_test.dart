import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/entities/income_data.dart';
import 'package:fintrack/features/analytics/domain/utils/running_income_service.dart';

void main() {
  group('RunningIncomeService Tests', () {
    final testPoints = [
      IncomePoint(date: DateTime(2026, 7, 1), amount: 100, runningTotal: 100),
      IncomePoint(date: DateTime(2026, 7, 2), amount: 150, runningTotal: 250),
      IncomePoint(date: DateTime(2026, 7, 3), amount: 200, runningTotal: 450),
      IncomePoint(date: DateTime(2026, 7, 4), amount: 50, runningTotal: 500),
    ];

    test('getRunningTotal returns correct value for valid index', () {
      expect(RunningIncomeService.getRunningTotal(testPoints, 0), 100);
      expect(RunningIncomeService.getRunningTotal(testPoints, 2), 450);
      expect(RunningIncomeService.getRunningTotal(testPoints, 3), 500);
    });

    test('getRunningTotal returns 0 for invalid index', () {
      expect(RunningIncomeService.getRunningTotal(testPoints, -1), 0);
      expect(RunningIncomeService.getRunningTotal(testPoints, 10), 0);
    });

    test('getCumulativeIncomeUpTo returns correct cumulative value', () {
      final date = DateTime(2026, 7, 3);
      final result = RunningIncomeService.getCumulativeIncomeUpTo(testPoints, date);
      expect(result, 450);
    });

    test('getAverageRunningIncome calculates average correctly', () {
      final result = RunningIncomeService.getAverageRunningIncome(testPoints);
      final expected = (100 + 250 + 450 + 500) / 4;
      expect(result, expected);
    });

    test('getRunningIncomeGrowth returns correct growth amount', () {
      final result = RunningIncomeService.getRunningIncomeGrowth(testPoints);
      expect(result, 400); // 500 - 100
    });

    test('getRunningIncomeGrowthPercentage calculates percentage correctly', () {
      final result = RunningIncomeService.getRunningIncomeGrowthPercentage(testPoints);
      expect(result, 400.0); // ((500 - 100) / 100) * 100
    });

    test('buildSummary creates correct summary', () {
      final summary = RunningIncomeService.buildSummary(testPoints);
      
      expect(summary.startingBalance, 0); // 100 - 100
      expect(summary.endingBalance, 500);
      expect(summary.totalAdded, 500); // 100 + 150 + 200 + 50
      expect(summary.growthAmount, 500); // 500 - 0
    });

    test('buildSummary returns zero values for empty list', () {
      final summary = RunningIncomeService.buildSummary([]);
      
      expect(summary.startingBalance, 0);
      expect(summary.endingBalance, 0);
      expect(summary.totalAdded, 0);
      expect(summary.growthAmount, 0);
    });

    test('projectFutureIncome estimates future income', () {
      final result = RunningIncomeService.projectFutureIncome(
        testPoints,
        const Duration(days: 7),
      );
      
      // Should project 7 days based on average of last two transactions
      expect(result, greaterThan(testPoints.last.runningTotal));
    });

    test('projectFutureIncome returns 0 with insufficient data', () {
      final singlePoint = [
        IncomePoint(
          date: DateTime(2026, 7, 1),
          amount: 100,
          runningTotal: 100,
        ),
      ];
      
      final result = RunningIncomeService.projectFutureIncome(
        singlePoint,
        const Duration(days: 7),
      );
      
      expect(result, 0);
    });

    test('IncomeRunningIncomeSummary calculates averages correctly', () {
      final points = [
        IncomePoint(
          date: DateTime(2026, 7, 1),
          amount: 1000,
          runningTotal: 1000,
        ),
      ];
      
      final summary = RunningIncomeService.buildSummary(points);
      expect(summary.averageRunningIncome, 1000);
    });
  });
}
