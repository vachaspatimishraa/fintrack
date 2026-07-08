/// Single category data point for chart.
class CategoryPoint {
  final String categoryName;
  final double amount;
  final double percentage;
  final int transactionCount;
  final String categoryColor;
  final String categoryIcon;

  const CategoryPoint({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    required this.categoryColor,
    required this.categoryIcon,
  });
}

/// Category ranking with position.
class CategoryRanking {
  final String categoryName;
  final double amount;
  final double percentage;
  final int rank;
  final int transactionCount;
  final String categoryColor;
  final String categoryIcon;
  final double averageAmount;

  const CategoryRanking({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.rank,
    required this.transactionCount,
    required this.categoryColor,
    required this.categoryIcon,
    required this.averageAmount,
  });
}

/// Category trend over time.
class CategoryTrend {
  final DateTime date;
  final String categoryName;
  final double amount;
  final int transactionCount;

  const CategoryTrend({
    required this.date,
    required this.categoryName,
    required this.amount,
    required this.transactionCount,
  });
}

/// Category comparison between periods.
class CategoryPeriodComparison {
  final String categoryName;
  final double currentAmount;
  final double previousAmount;
  final double growthPercentage;
  final bool isIncrease;

  const CategoryPeriodComparison({
    required this.categoryName,
    required this.currentAmount,
    required this.previousAmount,
    required this.growthPercentage,
    required this.isIncrease,
  });
}

/// Detailed category statistics.
class CategoryStatistics {
  final String categoryName;
  final double totalAmount;
  final double averageAmount;
  final double largestAmount;
  final double smallestAmount;
  final int transactionCount;
  final int averagePerDay;
  final int averagePerWeek;
  final int averagePerMonth;
  final String categoryColor;
  final String categoryIcon;

  const CategoryStatistics({
    required this.categoryName,
    required this.totalAmount,
    required this.averageAmount,
    required this.largestAmount,
    required this.smallestAmount,
    required this.transactionCount,
    required this.averagePerDay,
    required this.averagePerWeek,
    required this.averagePerMonth,
    required this.categoryColor,
    required this.categoryIcon,
  });
}

/// Detailed category information.
class CategoryDetails {
  final String categoryName;
  final double totalAmount;
  final double averageAmount;
  final double largestAmount;
  final double smallestAmount;
  final int transactionCount;
  final String categoryColor;
  final String categoryIcon;
  final List<CategoryTrend> trends;
  final List<CategoryPeriodComparison> monthlyComparisons;

  const CategoryDetails({
    required this.categoryName,
    required this.totalAmount,
    required this.averageAmount,
    required this.largestAmount,
    required this.smallestAmount,
    required this.transactionCount,
    required this.categoryColor,
    required this.categoryIcon,
    required this.trends,
    required this.monthlyComparisons,
  });
}

/// Master category analytics report.
class CategoryAnalyticsReport {
  final double totalAmount;
  final int categoryCount;
  final List<CategoryRanking> rankings;
  final List<CategoryRanking> expenseCategories;
  final List<CategoryRanking> incomeCategories;
  final List<CategoryPeriodComparison> comparisons;
  final CategoryRanking? topSpendingCategory;
  final CategoryRanking? leastSpendingCategory;
  final CategoryRanking? mostFrequentCategory;

  const CategoryAnalyticsReport({
    required this.totalAmount,
    required this.categoryCount,
    required this.rankings,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.comparisons,
    required this.topSpendingCategory,
    required this.leastSpendingCategory,
    required this.mostFrequentCategory,
  });

  factory CategoryAnalyticsReport.empty() => const CategoryAnalyticsReport(
        totalAmount: 0,
        categoryCount: 0,
        rankings: [],
        expenseCategories: [],
        incomeCategories: [],
        comparisons: [],
        topSpendingCategory: null,
        leastSpendingCategory: null,
        mostFrequentCategory: null,
      );

  bool get isEmpty => categoryCount == 0;
}
