import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/income_growth_calculator.dart';

void main() {
  group('IncomeGrowthCalculator Tests', () {
    test('calculateGrowthPercentage returns correct percentage increase', () {
      final result = IncomeGrowthCalculator.calculateGrowthPercentage(150, 100);
      expect(result, 50.0);
    });

    test('calculateGrowthPercentage returns correct percentage decrease', () {
      final result = IncomeGrowthCalculator.calculateGrowthPercentage(50, 100);
      expect(result, -50.0);
    });

    test('calculateGrowthPercentage handles zero previous value', () {
      final result = IncomeGrowthCalculator.calculateGrowthPercentage(100, 0);
      expect(result, 100.0);
    });

    test('calculateGrowthPercentage returns 0 when both are zero', () {
      final result = IncomeGrowthCalculator.calculateGrowthPercentage(0, 0);
      expect(result, 0.0);
    });

    test('getGrowthState returns increasing for positive growth', () {
      expect(IncomeGrowthCalculator.getGrowthState(10.0), 'increasing');
    });

    test('getGrowthState returns stable for near-zero growth', () {
      expect(IncomeGrowthCalculator.getGrowthState(3.0), 'stable');
      expect(IncomeGrowthCalculator.getGrowthState(-3.0), 'stable');
    });

    test('getGrowthState returns declining for negative growth', () {
      expect(IncomeGrowthCalculator.getGrowthState(-10.0), 'declining');
    });

    test('getGrowthColor returns correct color codes', () {
      expect(IncomeGrowthCalculator.getGrowthColor(10.0), 'success');
      expect(IncomeGrowthCalculator.getGrowthColor(-10.0), 'error');
      expect(IncomeGrowthCalculator.getGrowthColor(0.0), 'surface');
    });

    test('calculateAverageGrowthRate works with multiple periods', () {
      final periods = [100.0, 120.0, 132.0, 145.2];
      final result = IncomeGrowthCalculator.calculateAverageGrowthRate(periods);
      expect(result, greaterThan(0));
    });

    test('calculateAverageGrowthRate returns 0 with single period', () {
      final periods = [100.0];
      final result = IncomeGrowthCalculator.calculateAverageGrowthRate(periods);
      expect(result, 0.0);
    });

    test('calculateCAGR calculates compound annual growth rate correctly', () {
      // $100 growing to $1000 over 2 years
      final result = IncomeGrowthCalculator.calculateCAGR(100, 1000, 2);
      final expected = pow(1000 / 100, 1 / 2) - 1;
      expect(result, closeTo(expected, 0.0001));
    });

    test('getTrendDescription returns correct descriptions', () {
      expect(
        IncomeGrowthCalculator.getTrendDescription([100, 110]),
        'Moderate upward trend',
      );
      expect(
        IncomeGrowthCalculator.getTrendDescription([100, 90]),
        'Moderate downward trend',
      );
    });

    test('formatGrowth formats positive values with plus sign', () {
      expect(IncomeGrowthCalculator.formatGrowth(10.5), '+10.5%');
      expect(IncomeGrowthCalculator.formatGrowth(-10.5), '-10.5%');
    });
  });
}
