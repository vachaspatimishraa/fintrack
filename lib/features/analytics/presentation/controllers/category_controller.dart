import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category_data.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/utils/category_growth_calculator.dart';
import '../../domain/utils/category_ranking_service.dart';

/// Controller for category analytics business logic
class CategoryController {
  final CategoryRepository _repository;
  final Ref ref;

  CategoryController(this._repository, this.ref);

  /// Generate insights from category report
  List<String> generateInsights(CategoryAnalyticsReport report) {
    final insights = <String>[];

    if (report.isEmpty) return insights;

    // Top category insight
    if (report.topSpendingCategory != null) {
      final top = report.topSpendingCategory!;
      insights.add(
        '${top.categoryName} is your top category at ${top.percentage.toStringAsFixed(1)}% of spending',
      );
    }

    // Category count insight
    if (report.categoryCount > 5) {
      insights.add(
        'You have ${report.categoryCount} active spending categories',
      );
    }

    // Most frequent insight
    if (report.mostFrequentCategory != null) {
      final frequent = report.mostFrequentCategory!;
      insights.add(
        '${frequent.categoryName} is your most frequent category (${frequent.transactionCount} transactions)',
      );
    }

    // Growth insight
    if (report.comparisons.isNotEmpty) {
      final highestGrowth = report.comparisons
          .reduce((a, b) => a.growthPercentage.abs() > b.growthPercentage.abs() ? a : b);

      if (highestGrowth.growthPercentage.abs() > 10) {
        final direction = highestGrowth.isIncrease ? 'increased' : 'decreased';
        insights.add(
          '${highestGrowth.categoryName} $direction by ${highestGrowth.growthPercentage.toStringAsFixed(1)}%',
        );
      }
    }

    // Concentration insight
    final concentration = CategoryRankingService.calculateConcentration(report.rankings);
    final concentrationStr = CategoryRankingService.getConcentrationInterpretation(concentration);
    insights.add('Your spending is $concentrationStr');

    // Least used insight
    if (report.leastSpendingCategory != null) {
      final least = report.leastSpendingCategory!;
      insights.add(
        '${least.categoryName} is your least used category (${least.transactionCount} transactions)',
      );
    }

    return insights;
  }

  /// Get growth indicator for category
  String getGrowthIndicator(double growthPercentage) {
    if (growthPercentage > 0) return 'increase';
    if (growthPercentage < 0) return 'decrease';
    return 'neutral';
  }

  /// Format period label
  String getPeriodLabel(String timeFilter) {
    switch (timeFilter) {
      case 'today':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'quarter':
        return 'This Quarter';
      case 'year':
        return 'This Year';
      default:
        return 'Current Period';
    }
  }

  /// Check if report is empty
  bool isEmpty(CategoryAnalyticsReport report) {
    return report.isEmpty;
  }

  /// Get top categories for widget
  List<CategoryRanking> getTopCategories(
    CategoryAnalyticsReport report, {
    int limit = 5,
  }) {
    return CategoryRankingService.getTopCategories(report.rankings, limit: limit);
  }

  /// Get concentration description
  String getConcentrationDescription(List<CategoryRanking> rankings) {
    final concentration = CategoryRankingService.calculateConcentration(rankings);
    return CategoryRankingService.getConcentrationInterpretation(concentration);
  }

  /// Check if device is offline
  bool isOfflineMode() {
    return false; // Would be enhanced with connectivity check
  }

  /// Get category spending level
  String getCategoryLevel(double percentage) {
    return CategoryRankingService.categorizeCategoryLevel(percentage);
  }

  /// Get growth status for comparison
  String getGrowthStatus(double growthPercentage) {
    return CategoryGrowthCalculator.getGrowthStatus(growthPercentage);
  }
}
