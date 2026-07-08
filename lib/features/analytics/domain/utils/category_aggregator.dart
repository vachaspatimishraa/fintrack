import 'dart:math';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/category_data.dart';

class CategoryAggregator {
  /// Aggregate category data based on time filter
  static CategoryAnalyticsReport aggregate({
    required List<TransactionEntity> transactions,
    required String timeFilter,
  }) {
    if (transactions.isEmpty) {
      return CategoryAnalyticsReport.empty();
    }

    // Filter transactions by time
    final filteredTx = _filterByTimeFrame(transactions, timeFilter);
    final previousTx = _getPreviousPeriod(transactions, timeFilter);

    if (filteredTx.isEmpty) {
      return CategoryAnalyticsReport.empty();
    }

    // Calculate total
    final totalAmount = filteredTx.fold<double>(0, (sum, tx) => sum + tx.amount);

    // Build rankings for all categories
    final rankings = _buildCategoryRankings(filteredTx, totalAmount);

    // Separate expense and income categories
    final expenseCategories = _getExpenseCategories(filteredTx, totalAmount);
    final incomeCategories = _getIncomeCategories(filteredTx, totalAmount);

    // Calculate comparisons
    final comparisons = _calculateCategoryComparisons(filteredTx, previousTx);

    // Find special categories
    final topSpending = rankings.isNotEmpty ? rankings.first : null;
    final leastSpending = rankings.isNotEmpty ? rankings.last : null;
    final mostFrequent = _findMostFrequentCategory(filteredTx, totalAmount);

    return CategoryAnalyticsReport(
      totalAmount: totalAmount,
      categoryCount: rankings.length,
      rankings: rankings,
      expenseCategories: expenseCategories,
      incomeCategories: incomeCategories,
      comparisons: comparisons,
      topSpendingCategory: topSpending,
      leastSpendingCategory: leastSpending,
      mostFrequentCategory: mostFrequent,
    );
  }

  /// Get detailed category information
  static CategoryDetails getCategoryDetails({
    required List<TransactionEntity> transactions,
    required String categoryName,
    required String timeFilter,
  }) {
    // Filter by category
    final categoryTx = transactions
        .where((tx) => !tx.isDeleted && tx.category == categoryName)
        .toList();

    if (categoryTx.isEmpty) {
      return CategoryDetails(
        categoryName: categoryName,
        totalAmount: 0,
        averageAmount: 0,
        largestAmount: 0,
        smallestAmount: 0,
        transactionCount: 0,
        categoryColor: '#FF0000',
        categoryIcon: 'category',
        trends: [],
        monthlyComparisons: [],
      );
    }

    // Get category properties from first transaction
    final categoryColor = categoryTx.first.categoryColor;
    final categoryIcon = categoryTx.first.categoryIcon;

    // Filter by time
    final filteredTx = _filterByTimeFrame(categoryTx, timeFilter);
    final totalAmount = filteredTx.fold<double>(0, (sum, tx) => sum + tx.amount);
    final averageAmount = filteredTx.isNotEmpty
        ? totalAmount / filteredTx.length
        : 0.0;

    double largestAmount = 0;
    double smallestAmount = double.infinity;

    for (final tx in filteredTx) {
      largestAmount = max(largestAmount, tx.amount);
      smallestAmount = min(smallestAmount, tx.amount);
    }

    if (smallestAmount == double.infinity) {
      smallestAmount = 0;
    }

    final avgPerDay = filteredTx.isNotEmpty
        ? (totalAmount / _getDateRangeInDays(filteredTx)).ceil()
        : 0;
    final avgPerWeek = (avgPerDay * 7).ceil();
    final avgPerMonth = (avgPerDay * 30).ceil();

    // Build trends
    final trends = _buildCategoryTrends(filteredTx, categoryName);

    // Build monthly comparisons
    final monthlyComparisons = _getCategoryMonthlyComparisons(
      transactions: categoryTx,
      categoryName: categoryName,
      timeFilter: timeFilter,
    );

    return CategoryDetails(
      categoryName: categoryName,
      totalAmount: totalAmount,
      averageAmount: averageAmount,
      largestAmount: largestAmount,
      smallestAmount: smallestAmount,
      transactionCount: filteredTx.length,
      categoryColor: categoryColor,
      categoryIcon: categoryIcon,
      trends: trends,
      monthlyComparisons: monthlyComparisons,
    );
  }

  /// Build category rankings sorted by amount
  static List<CategoryRanking> _buildCategoryRankings(
    List<TransactionEntity> transactions,
    double total,
  ) {
    final categoryMap = <String, (double, int, String, String)>{};

    for (final tx in transactions) {
      final key = (categoryMap[tx.category]?.$1 ?? 0.0) + tx.amount;
      final count = (categoryMap[tx.category]?.$2 ?? 0) + 1;
      categoryMap[tx.category] = (
        key,
        count,
        tx.categoryColor,
        tx.categoryIcon,
      );
    }

    final rankings = <CategoryRanking>[];
    int rank = 1;

    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.$1.compareTo(a.value.$1));

    for (final entry in sortedCategories) {
      final amount = entry.value.$1;
      final count = entry.value.$2;
      final percentage = total > 0 ? (amount / total) * 100 : 0.0;
      final avgAmount = count > 0 ? amount / count : 0.0;

      rankings.add(CategoryRanking(
        categoryName: entry.key,
        amount: amount,
        percentage: percentage,
        rank: rank,
        transactionCount: count,
        categoryColor: entry.value.$3,
        categoryIcon: entry.value.$4,
        averageAmount: avgAmount,
      ));

      rank++;
    }

    return rankings;
  }

  /// Get expense categories only
  static List<CategoryRanking> _getExpenseCategories(
    List<TransactionEntity> transactions,
    double total,
  ) {
    final expenseTx = transactions.where((tx) => tx.type == 'expense').toList();
    if (expenseTx.isEmpty) return [];

    final expenseTotal = expenseTx.fold<double>(0, (sum, tx) => sum + tx.amount);
    return _buildCategoryRankings(expenseTx, expenseTotal);
  }

  /// Get income categories only
  static List<CategoryRanking> _getIncomeCategories(
    List<TransactionEntity> transactions,
    double total,
  ) {
    final incomeTx = transactions.where((tx) => tx.type == 'income').toList();
    if (incomeTx.isEmpty) return [];

    final incomeTotal = incomeTx.fold<double>(0, (sum, tx) => sum + tx.amount);
    return _buildCategoryRankings(incomeTx, incomeTotal);
  }

  /// Calculate category comparisons between periods
  static List<CategoryPeriodComparison> _calculateCategoryComparisons(
    List<TransactionEntity> currentPeriod,
    List<TransactionEntity> previousPeriod,
  ) {
    final comparisons = <CategoryPeriodComparison>[];

    // Group current period by category
    final currentMap = <String, double>{};
    for (final tx in currentPeriod) {
      currentMap[tx.category] = (currentMap[tx.category] ?? 0) + tx.amount;
    }

    // Group previous period by category
    final previousMap = <String, double>{};
    for (final tx in previousPeriod) {
      previousMap[tx.category] = (previousMap[tx.category] ?? 0) + tx.amount;
    }

    // Calculate comparisons for all categories
    final allCategories = {...currentMap.keys, ...previousMap.keys};
    for (final category in allCategories) {
      final current = currentMap[category] ?? 0.0;
      final previous = previousMap[category] ?? 0.0;

      double growth = 0.0;
      if (previous > 0) {
        growth = ((current - previous) / previous) * 100;
      }

      comparisons.add(CategoryPeriodComparison(
        categoryName: category,
        currentAmount: current,
        previousAmount: previous,
        growthPercentage: growth,
        isIncrease: growth >= 0,
      ));
    }

    return comparisons;
  }

  /// Find most frequent category
  static CategoryRanking? _findMostFrequentCategory(
    List<TransactionEntity> transactions,
    double total,
  ) {
    if (transactions.isEmpty) return null;

    final categoryCount = <String, int>{};
    final categoryAmount = <String, double>{};
    final categoryProps = <String, (String, String)>{};

    for (final tx in transactions) {
      categoryCount[tx.category] = (categoryCount[tx.category] ?? 0) + 1;
      categoryAmount[tx.category] =
          (categoryAmount[tx.category] ?? 0) + tx.amount;
      categoryProps[tx.category] = (
        tx.categoryColor,
        tx.categoryIcon,
      );
    }

    final mostFrequent = categoryCount.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    final categoryName = mostFrequent.key;
    final amount = categoryAmount[categoryName] ?? 0.0;
    final percentage = total > 0 ? (amount / total) * 100 : 0.0;
    final props = categoryProps[categoryName]!;

    return CategoryRanking(
      categoryName: categoryName,
      amount: amount,
      percentage: percentage,
      rank: 1,
      transactionCount: mostFrequent.value,
      categoryColor: props.$1,
      categoryIcon: props.$2,
      averageAmount: amount / mostFrequent.value,
    );
  }

  /// Build category trends
  static List<CategoryTrend> _buildCategoryTrends(
    List<TransactionEntity> transactions,
    String categoryName,
  ) {
    final trendMap = <DateTime, (double, int)>{};

    for (final tx in transactions) {
      final dayKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final (amount, count) = trendMap[dayKey] ?? (0.0, 0);
      trendMap[dayKey] = (amount + tx.amount, count + 1);
    }

    return trendMap.entries
        .map((e) => CategoryTrend(
              date: e.key,
              categoryName: categoryName,
              amount: e.value.$1,
              transactionCount: e.value.$2,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get category monthly comparisons
  static List<CategoryPeriodComparison> _getCategoryMonthlyComparisons({
    required List<TransactionEntity> transactions,
    required String categoryName,
    required String timeFilter,
  }) {
    final categoryTx =
        transactions.where((tx) => tx.category == categoryName).toList();

    if (categoryTx.isEmpty) return [];

    final now = DateTime.now();
    final comparisons = <CategoryPeriodComparison>[];

    // Current month
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 1);
    final currentMonthAmount = categoryTx
        .where((tx) =>
            !tx.date.isBefore(currentMonthStart) &&
            tx.date.isBefore(currentMonthEnd))
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    // Previous month
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    final previousMonthEnd = DateTime(now.year, now.month, 1);
    final previousMonthAmount = categoryTx
        .where((tx) =>
            !tx.date.isBefore(previousMonthStart) &&
            tx.date.isBefore(previousMonthEnd))
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    double growth = 0.0;
    if (previousMonthAmount > 0) {
      growth =
          ((currentMonthAmount - previousMonthAmount) / previousMonthAmount) *
              100;
    }

    comparisons.add(CategoryPeriodComparison(
      categoryName: categoryName,
      currentAmount: currentMonthAmount,
      previousAmount: previousMonthAmount,
      growthPercentage: growth,
      isIncrease: growth >= 0,
    ));

    return comparisons;
  }

  /// Filter transactions by time frame
  static List<TransactionEntity> _filterByTimeFrame(
    List<TransactionEntity> transactions,
    String timeFilter,
  ) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeFilter) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'quarter':
        final quarter = (now.month - 1) ~/ 3;
        startDate = DateTime(now.year, quarter * 3 + 1, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    return transactions
        .where((tx) => !tx.isDeleted && !tx.date.isBefore(startDate))
        .toList();
  }

  /// Get previous period transactions
  static List<TransactionEntity> _getPreviousPeriod(
    List<TransactionEntity> transactions,
    String timeFilter,
  ) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (timeFilter) {
      case 'today':
        final yesterday = now.subtract(const Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        endDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: 7 + now.weekday - 1));
        endDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'month':
        final lastMonth = DateTime(now.year, now.month - 1);
        startDate = DateTime(lastMonth.year, lastMonth.month, 1);
        endDate = DateTime(now.year, now.month, 1);
        break;
      case 'quarter':
        final quarter = (now.month - 1) ~/ 3;
        final lastQuarter = (quarter - 1 + 4) % 4;
        startDate = DateTime(now.year, lastQuarter * 3 + 1, 1);
        endDate = DateTime(now.year, quarter * 3 + 1, 1);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, 1, 1);
        endDate = DateTime(now.year, 1, 1);
        break;
      default:
        final lastMonth = DateTime(now.year, now.month - 1);
        startDate = DateTime(lastMonth.year, lastMonth.month, 1);
        endDate = DateTime(now.year, now.month, 1);
    }

    return transactions
        .where((tx) =>
            !tx.isDeleted &&
            !tx.date.isBefore(startDate) &&
            tx.date.isBefore(endDate))
        .toList();
  }

  /// Get date range in days
  static int _getDateRangeInDays(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return 1;

    final dates = transactions.map((tx) => tx.date).toSet();
    if (dates.isEmpty) return 1;

    final sorted = dates.toList()..sort();
    final daysDiff = sorted.last.difference(sorted.first).inDays + 1;

    return max(1, daysDiff);
  }
}
