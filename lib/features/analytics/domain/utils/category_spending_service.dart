import '../entities/expense_data.dart';

/// Service for analyzing spending patterns and category insights
class CategorySpendingService {
  /// Calculate category trends
  static Map<String, double> calculateCategoryTrends(List<ExpenseCategorySlice> categories) {
    final trends = <String, double>{};
    for (final cat in categories) {
      trends[cat.categoryName] = cat.amount;
    }
    return trends;
  }

  /// Find overspending categories
  static List<ExpenseCategorySlice> findOverspendingCategories(
    List<ExpenseCategorySlice> categories,
    double threshold, // percentage threshold
  ) {
    return categories.where((cat) => cat.percentage > threshold).toList();
  }

  /// Calculate category variability
  static Map<String, double> calculateCategoryVariability(
    List<ExpenseCategorySlice> categories,
  ) {
    final total = categories.fold<double>(0, (sum, cat) => sum + cat.amount);
    final avg = categories.isNotEmpty ? total / categories.length : 0;
    final variance = categories
        .map((cat) => (cat.amount - avg) * (cat.amount - avg))
        .fold<double>(0, (sum, v) => sum + v);

    final variability = <String, double>{};
    for (final cat in categories) {
      variability[cat.categoryName] = ((cat.amount - avg) / avg).abs() * 100;
    }
    return variability;
  }

  /// Get category recommendations
  static List<String> getSpendingRecommendations(
    List<ExpenseCategorySlice> categories,
    double totalExpense,
  ) {
    final recommendations = <String>[];

    if (categories.isEmpty) return recommendations;

    // Identify top spending category
    final topCategory = categories.first;
    recommendations.add(
      'Top spending: ${topCategory.categoryName} at ${topCategory.percentage.toStringAsFixed(1)}%',
    );

    // Identify categories over 25% of total
    final highCategories = categories.where((c) => c.percentage > 25).toList();
    if (highCategories.length > 1) {
      final names = highCategories.map((c) => c.categoryName).join(', ');
      recommendations.add('Multiple high-spending categories detected: $names');
    }

    // Suggest optimization for top category
    if (topCategory.percentage > 40) {
      recommendations.add(
        'Consider reducing ${topCategory.categoryName} - it represents over 40% of your spending',
      );
    }

    // Identify categories with many transactions
    final frequentCategories = categories.where((c) => c.transactionCount > 10).toList();
    if (frequentCategories.isNotEmpty) {
      final names = frequentCategories.map((c) => c.categoryName).join(', ');
      recommendations.add('High-frequency spending in: $names');
    }

    return recommendations;
  }

  /// Calculate category budget utilization
  static Map<String, double> calculateBudgetUtilization(
    List<ExpenseCategorySlice> categories,
    Map<String, double> budgets, // category -> budget amount
  ) {
    final utilization = <String, double>{};
    for (final cat in categories) {
      final budget = budgets[cat.categoryName] ?? 0;
      if (budget > 0) {
        utilization[cat.categoryName] = (cat.amount / budget) * 100;
      }
    }
    return utilization;
  }

  /// Get category status (over/under budget)
  static Map<String, String> getCategoryBudgetStatus(
    List<ExpenseCategorySlice> categories,
    Map<String, double> budgets,
  ) {
    final utilization = calculateBudgetUtilization(categories, budgets);
    final status = <String, String>{};

    for (final entry in utilization.entries) {
      if (entry.value > 100) {
        status[entry.key] = 'over_budget';
      } else if (entry.value > 80) {
        status[entry.key] = 'near_limit';
      } else if (entry.value > 50) {
        status[entry.key] = 'on_track';
      } else {
        status[entry.key] = 'under_limit';
      }
    }

    return status;
  }

  static List<(String, double)> rankCategoriesByEfficiency(
    List<ExpenseCategorySlice> categories,
  ) {
    final efficiency = <(String, double)>[];
    for (final cat in categories) {
      final double perTransaction = cat.transactionCount > 0 
          ? (cat.amount / cat.transactionCount) 
          : 0.0;
      efficiency.add((cat.categoryName, perTransaction));
    }
    efficiency.sort((a, b) => b.$2.compareTo(a.$2));
    return efficiency;
  }
}
