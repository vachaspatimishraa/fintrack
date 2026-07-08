import 'dart:math';

/// Utility class for income growth calculations
class IncomeGrowthCalculator {
  /// Calculate growth percentage between two values
  ///
  /// Formula: ((Current - Previous) / Previous) × 100
  static double calculateGrowthPercentage(double current, double previous) {
    if (previous == 0) {
      return current > 0 ? 100.0 : 0.0;
    }
    return ((current - previous) / previous) * 100;
  }

  /// Determine growth state based on percentage
  static String getGrowthState(double growthPercentage) {
    if (growthPercentage > 5) return 'increasing';
    if (growthPercentage < -5) return 'declining';
    return 'stable';
  }

  /// Get growth indicator color
  static String getGrowthColor(double growthPercentage) {
    if (growthPercentage > 0) return 'success'; // Green
    if (growthPercentage < 0) return 'error'; // Red
    return 'surface'; // Grey
  }

  /// Calculate average growth rate over multiple periods
  static double calculateAverageGrowthRate(List<double> periodValues) {
    if (periodValues.length < 2) return 0.0;

    double totalGrowth = 0.0;
    for (int i = 1; i < periodValues.length; i++) {
      final growth = calculateGrowthPercentage(periodValues[i], periodValues[i - 1]);
      totalGrowth += growth;
    }

    return totalGrowth / (periodValues.length - 1);
  }

  /// Calculate compound annual growth rate (CAGR)
  ///
  /// Formula: (Ending Value / Beginning Value)^(1/Number of Years) - 1
  static double calculateCAGR(
    double beginningValue,
    double endingValue,
    int numberOfYears,
  ) {
    if (beginningValue == 0 || numberOfYears == 0) return 0.0;
    return (pow(endingValue / beginningValue, 1 / numberOfYears) as double) - 1;
  }

  /// Get trend description based on growth values
  static String getTrendDescription(List<double> values) {
    if (values.length < 2) return 'Insufficient data';

    final recentGrowth = calculateGrowthPercentage(values.last, values[values.length - 2]);

    if (recentGrowth > 15) {
      return 'Strong upward trend';
    } else if (recentGrowth > 5) {
      return 'Moderate upward trend';
    } else if (recentGrowth > -5) {
      return 'Stable trend';
    } else if (recentGrowth > -15) {
      return 'Moderate downward trend';
    } else {
      return 'Strong downward trend';
    }
  }

  /// Format growth percentage for display
  static String formatGrowth(double growthPercentage) {
    final sign = growthPercentage > 0 ? '+' : '';
    return '$sign${growthPercentage.toStringAsFixed(1)}%';
  }
}
