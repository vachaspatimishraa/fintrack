import '../entities/category_data.dart';

/// Service for category ranking and sorting
class CategoryRankingService {
  /// Get top N categories by amount
  static List<CategoryRanking> getTopCategories(
    List<CategoryRanking> rankings, {
    int limit = 5,
  }) {
    return rankings.take(limit).toList();
  }

  /// Get bottom N categories by amount
  static List<CategoryRanking> getBottomCategories(
    List<CategoryRanking> rankings, {
    int limit = 5,
  }) {
    return rankings.reversed.take(limit).toList();
  }

  /// Sort rankings by amount (descending)
  static List<CategoryRanking> sortByAmount(List<CategoryRanking> rankings) {
    final sorted = List<CategoryRanking>.from(rankings);
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted;
  }

  /// Sort rankings by transaction count (descending)
  static List<CategoryRanking> sortByFrequency(List<CategoryRanking> rankings) {
    final sorted = List<CategoryRanking>.from(rankings);
    sorted.sort((a, b) => b.transactionCount.compareTo(a.transactionCount));
    return sorted;
  }

  /// Sort rankings by average amount (descending)
  static List<CategoryRanking> sortByAverage(List<CategoryRanking> rankings) {
    final sorted = List<CategoryRanking>.from(rankings);
    sorted.sort((a, b) => b.averageAmount.compareTo(a.averageAmount));
    return sorted;
  }

  /// Get categories above threshold percentage
  static List<CategoryRanking> getCategoriesAboveThreshold(
    List<CategoryRanking> rankings,
    double percentageThreshold,
  ) {
    return rankings.where((r) => r.percentage >= percentageThreshold).toList();
  }

  /// Get categories below threshold percentage
  static List<CategoryRanking> getCategoriesBelowThreshold(
    List<CategoryRanking> rankings,
    double percentageThreshold,
  ) {
    return rankings.where((r) => r.percentage < percentageThreshold).toList();
  }

  /// Calculate category concentration (Herfindahl index)
  static double calculateConcentration(List<CategoryRanking> rankings) {
    if (rankings.isEmpty) return 0.0;

    double hIndex = 0.0;
    for (final rank in rankings) {
      final percentage = rank.percentage / 100;
      hIndex += percentage * percentage;
    }

    return hIndex;
  }

  /// Get concentration interpretation
  static String getConcentrationInterpretation(double hIndex) {
    if (hIndex > 0.5) return 'Highly Concentrated';
    if (hIndex > 0.25) return 'Moderately Concentrated';
    if (hIndex > 0.15) return 'Diversified';
    return 'Well Diversified';
  }

  /// Find categories with unusual growth
  static List<CategoryPeriodComparison> findUnusualGrowth(
    List<CategoryPeriodComparison> comparisons, {
    double threshold = 20.0,
  }) {
    return comparisons
        .where((c) => c.growthPercentage.abs() > threshold)
        .toList();
  }

  /// Get category growth distribution
  static Map<String, int> getGrowthDistribution(
    List<CategoryPeriodComparison> comparisons,
  ) {
    int increased = 0;
    int stable = 0;
    int decreased = 0;

    for (final comp in comparisons) {
      if (comp.growthPercentage > 5) {
        increased++;
      } else if (comp.growthPercentage < -5) {
        decreased++;
      } else {
        stable++;
      }
    }

    return {
      'increased': increased,
      'stable': stable,
      'decreased': decreased,
    };
  }

  /// Categorize spending level based on percentage
  static String categorizeCategoryLevel(double percentage) {
    if (percentage > 40) return 'dominant';
    if (percentage > 20) return 'major';
    if (percentage > 10) return 'moderate';
    if (percentage > 5) return 'minor';
    return 'negligible';
  }

  /// Get top and bottom categories together
  static Map<String, List<CategoryRanking>> getExtremes(
    List<CategoryRanking> rankings, {
    int limit = 3,
  }) {
    return {
      'top': getTopCategories(rankings, limit: limit),
      'bottom': getBottomCategories(rankings, limit: limit),
    };
  }
}
