
/// Utility class for expense growth calculations
class ExpenseGrowthCalculator {
  /// Calculate growth percentage between two values
  ///
  /// Formula: ((Current - Previous) / Previous) × 100
  static double calculateGrowthPercentage(double current, double previous) {
    if (previous == 0) {
      return current > 0 ? 100.0 : 0.0;
    }
    return ((current - previous) / previous) * 100;
  }

  /// Determine expense trend
  static String getExpenseTrend(double growthPercentage) {
    if (growthPercentage > 10) return 'escalating';
    if (growthPercentage > 0) return 'increasing';
    if (growthPercentage < -10) return 'decreasing';
    if (growthPercentage < 0) return 'declining';
    return 'stable';
  }

  /// Get spending status based on growth
  static String getSpendingStatus(double growthPercentage) {
    if (growthPercentage > 20) return 'critical';
    if (growthPercentage > 10) return 'warning';
    if (growthPercentage > 0) return 'caution';
    return 'good';
  }

  /// Get indicator color for growth
  static String getGrowthColor(double growthPercentage) {
    if (growthPercentage > 0) return 'error'; // Red for increase
    if (growthPercentage < 0) return 'success'; // Green for decrease
    return 'surface'; // Grey for neutral
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

  /// Format growth percentage for display
  static String formatGrowth(double growthPercentage) {
    final sign = growthPercentage > 0 ? '+' : '';
    return '$sign${growthPercentage.toStringAsFixed(1)}%';
  }

  /// Get spending trend description
  static String getTrendDescription(List<double> values) {
    if (values.length < 2) return 'Insufficient data';

    final recentGrowth = calculateGrowthPercentage(values.last, values[values.length - 2]);

    if (recentGrowth > 25) {
      return 'Rapidly escalating spending';
    } else if (recentGrowth > 10) {
      return 'Spending trending upward';
    } else if (recentGrowth > 0) {
      return 'Slight increase in spending';
    } else if (recentGrowth > -10) {
      return 'Stable spending';
    } else if (recentGrowth > -25) {
      return 'Spending trending downward';
    } else {
      return 'Rapid spending decrease';
    }
  }

  /// Categorize spending level
  static String categorizeSpendinLevel(double monthlyExpense, double monthlyIncome) {
    if (monthlyIncome == 0) return 'unknown';
    final ratio = (monthlyExpense / monthlyIncome) * 100;

    if (ratio > 80) return 'unsustainable';
    if (ratio > 60) return 'high';
    if (ratio > 40) return 'moderate';
    if (ratio > 20) return 'conservative';
    return 'minimal';
  }

  /// Get budget recommendation
  static String getBudgetRecommendation(double monthlyExpense, double monthlyIncome) {
    if (monthlyIncome == 0) return 'Unable to calculate - no income data';

    final percentOfIncome = (monthlyExpense / monthlyIncome) * 100;

    if (percentOfIncome > 80) {
      return 'Expense is ${percentOfIncome.toStringAsFixed(0)}% of income - UNSUSTAINABLE. Reduce spending urgently.';
    } else if (percentOfIncome > 60) {
      return 'Expense is ${percentOfIncome.toStringAsFixed(0)}% of income - HIGH. Consider reducing non-essential spending.';
    } else if (percentOfIncome > 50) {
      return 'Expense is ${percentOfIncome.toStringAsFixed(0)}% of income - MODERATE. Leave room for savings.';
    } else if (percentOfIncome > 30) {
      return 'Expense is ${percentOfIncome.toStringAsFixed(0)}% of income - HEALTHY. Good balance between spending and saving.';
    } else {
      return 'Expense is ${percentOfIncome.toStringAsFixed(0)}% of income - EXCELLENT. Strong savings potential.';
    }
  }
}
