import '../entities/category_data.dart';

/// Utility for category growth calculations
class CategoryGrowthCalculator {
  /// Calculate growth percentage between two amounts
  static double calculateGrowth(double current, double previous) {
    if (previous == 0) {
      return current > 0 ? 100.0 : 0.0;
    }
    return ((current - previous) / previous) * 100;
  }

  /// Get growth status
  static String getGrowthStatus(double growthPercentage) {
    if (growthPercentage > 20) return 'critical_increase';
    if (growthPercentage > 10) return 'significant_increase';
    if (growthPercentage > 0) return 'slight_increase';
    if (growthPercentage > -10) return 'stable';
    if (growthPercentage > -20) return 'slight_decrease';
    return 'significant_decrease';
  }

  /// Get growth color
  static String getGrowthColor(double growthPercentage) {
    if (growthPercentage > 0) return 'error';
    if (growthPercentage < 0) return 'success';
    return 'surface';
  }

  /// Format growth percentage for display
  static String formatGrowth(double growthPercentage) {
    final sign = growthPercentage > 0 ? '+' : '';
    return '$sign${growthPercentage.toStringAsFixed(1)}%';
  }

  /// Get trend description
  static String getTrendDescription(List<double> values) {
    if (values.length < 2) return 'Insufficient data';

    final recent = calculateGrowth(values.last, values[values.length - 2]);

    if (recent > 25) {
      return 'Rapidly increasing';
    } else if (recent > 10) {
      return 'Trending upward';
    } else if (recent > 0) {
      return 'Slight increase';
    } else if (recent > -10) {
      return 'Stable';
    } else if (recent > -25) {
      return 'Trending downward';
    } else {
      return 'Rapidly decreasing';
    }
  }

  /// Calculate average growth rate across periods
  static double calculateAverageGrowth(List<CategoryPeriodComparison> comparisons) {
    if (comparisons.isEmpty) return 0.0;

    double totalGrowth = 0.0;
    for (final comparison in comparisons) {
      totalGrowth += comparison.growthPercentage;
    }

    return totalGrowth / comparisons.length;
  }
}
