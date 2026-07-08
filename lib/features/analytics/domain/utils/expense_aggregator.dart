import 'dart:math';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/expense_data.dart';

class ExpenseAggregator {
  /// Aggregate expense data based on time filter
  static ExpenseReport aggregate({
    required List<TransactionEntity> transactions,
    required String timeFilter,
  }) {
    // Filter transactions to expense only and not deleted
    final allExpenseTx = transactions
        .where((tx) => !tx.isDeleted && tx.type == 'expense')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Get filtered transactions based on time filter
    final filteredTx = _filterByTimeFrame(allExpenseTx, timeFilter);
    final previousTx = _getPreviousPeriod(allExpenseTx, timeFilter);

    if (filteredTx.isEmpty) {
      return ExpenseReport.empty();
    }

    // Calculate basic statistics
    final statistics = _calculateStatistics(filteredTx);
    final comparison = _calculateComparison(filteredTx, previousTx);

    // Build data points for chart
    final points = _buildExpensePoints(filteredTx);

    // Build category distribution
    final categories = _buildCategoryDistribution(filteredTx, statistics.totalExpense);

    // Build merchant distribution
    final merchants = _buildMerchantDistribution(filteredTx, statistics.totalExpense);

    // Build calendar data
    final calendarData = _buildCalendarData(filteredTx);

    // Find highest and lowest expense info
    final highestExpenseInfo = _findHighestExpenseInfo(filteredTx);
    final lowestExpenseInfo = _findLowestExpenseInfo(filteredTx);

    // Detect unusual expenses
    final unusualExpenses = _detectUnusualExpenses(filteredTx, statistics);

    // Detect recurring patterns
    final recurringPatterns = _detectRecurringPatterns(allExpenseTx);

    // Calculate health score
    final healthScore = _calculateHealthScore(statistics, comparison, recurringPatterns);

    // Build heatmap data
    final heatmapData = _buildHeatmapData(filteredTx);

    return ExpenseReport(
      totalExpense: statistics.totalExpense,
      growthPercentage: comparison.growthPercentage,
      averageExpense: statistics.averageExpense,
      highestExpense: statistics.highestExpense,
      lowestExpense: statistics.lowestExpense,
      expenseCount: statistics.expenseCount,
      highestExpenseInfo: highestExpenseInfo,
      lowestExpenseInfo: lowestExpenseInfo,
      points: points,
      categories: categories,
      merchants: merchants,
      statistics: statistics,
      comparison: comparison,
      calendarData: calendarData,
      unusualExpenses: unusualExpenses,
      recurringPatterns: recurringPatterns,
      healthScore: healthScore,
      heatmapData: heatmapData,
    );
  }

  /// Calculate detailed expense statistics
  static ExpenseStatistics _calculateStatistics(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return ExpenseStatistics.empty();
    }

    double total = 0.0;
    double highest = 0.0;
    double lowest = double.infinity;
    final amounts = <double>[];
    final Set<DateTime> daysSet = {};

    for (final tx in transactions) {
      total += tx.amount;
      amounts.add(tx.amount);
      highest = max(highest, tx.amount);
      lowest = min(lowest, tx.amount);
      daysSet.add(DateTime(tx.date.year, tx.date.month, tx.date.day));
    }

    final average = total / transactions.length;
    final median = _calculateMedian(amounts);
    final stdDev = _calculateStandardDeviation(amounts, average);
    final daysSpan = max(1, daysSet.length);
    final averagePerDay = total / daysSpan;
    final averagePerWeek = averagePerDay * 7;
    final averagePerMonth = averagePerDay * 30;

    return ExpenseStatistics(
      totalExpense: total,
      averageExpense: average,
      highestExpense: highest,
      lowestExpense: lowest == double.infinity ? 0.0 : lowest,
      expenseCount: transactions.length,
      averagePerDay: averagePerDay,
      averagePerWeek: averagePerWeek,
      averagePerMonth: averagePerMonth,
      medianExpense: median,
      standardDeviation: stdDev,
    );
  }

  /// Calculate period comparison
  static ExpensePeriodComparison _calculateComparison(
    List<TransactionEntity> currentPeriod,
    List<TransactionEntity> previousPeriod,
  ) {
    double currentTotal = currentPeriod.fold(0.0, (sum, tx) => sum + tx.amount);
    double previousTotal = previousPeriod.fold(0.0, (sum, tx) => sum + tx.amount);

    double growthPercentage = 0.0;
    if (previousTotal > 0) {
      growthPercentage = ((currentTotal - previousTotal) / previousTotal) * 100;
    }

    return ExpensePeriodComparison(
      currentPeriodExpense: currentTotal,
      previousPeriodExpense: previousTotal,
      growthPercentage: growthPercentage,
      isIncreasing: growthPercentage >= 0,
    );
  }

  /// Build expense points for chart visualization
  static List<ExpensePoint> _buildExpensePoints(List<TransactionEntity> transactions) {
    final points = <ExpensePoint>[];
    double runningTotal = 0.0;

    for (final tx in transactions) {
      runningTotal += tx.amount;
      points.add(ExpensePoint(
        date: tx.date,
        amount: tx.amount,
        runningTotal: runningTotal,
      ));
    }

    return points;
  }

  /// Build category distribution
  static List<ExpenseCategorySlice> _buildCategoryDistribution(
    List<TransactionEntity> transactions,
    double total,
  ) {
    final categoryMap = <String, (double, int)>{};

    for (final tx in transactions) {
      final (amount, count) = categoryMap[tx.category] ?? (0.0, 0);
      categoryMap[tx.category] = (amount + tx.amount, count + 1);
    }

    return categoryMap.entries
        .map((e) => ExpenseCategorySlice(
              categoryName: e.key,
              amount: e.value.$1,
              percentage: total > 0 ? (e.value.$1 / total) * 100 : 0.0,
              transactionCount: e.value.$2,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  /// Build merchant distribution
  static List<MerchantSlice> _buildMerchantDistribution(
    List<TransactionEntity> transactions,
    double total,
  ) {
    final merchantMap = <String, (double, int)>{};

    for (final tx in transactions) {
      final (amount, count) = merchantMap[tx.merchant] ?? (0.0, 0);
      merchantMap[tx.merchant] = (amount + tx.amount, count + 1);
    }

    return merchantMap.entries
        .map((e) => MerchantSlice(
              merchantName: e.key,
              amount: e.value.$1,
              transactionCount: e.value.$2,
              percentage: total > 0 ? (e.value.$1 / total) * 100 : 0.0,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  /// Build calendar data
  static List<ExpenseCalendarDay> _buildCalendarData(List<TransactionEntity> transactions) {
    final dateMap = <DateTime, List<TransactionEntity>>{};

    for (final tx in transactions) {
      final dayKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      dateMap.putIfAbsent(dayKey, () => []).add(tx);
    }

    return dateMap.entries
        .map((e) {
          final dayTotal = e.value.fold(0.0, (sum, tx) => sum + tx.amount);
          final topCategory = _getTopCategory(e.value);
          return ExpenseCalendarDay(
            date: e.key,
            totalExpense: dayTotal,
            expenseCount: e.value.length,
            topCategory: topCategory,
          );
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Find highest expense transaction info
  static HighestExpenseInfo? _findHighestExpenseInfo(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return null;

    TransactionEntity? highest;
    for (final tx in transactions) {
      if (highest == null || tx.amount > highest.amount) {
        highest = tx;
      }
    }

    if (highest == null) return null;

    return HighestExpenseInfo(
      merchant: highest.merchant,
      amount: highest.amount,
      date: highest.date,
      category: highest.category,
    );
  }

  /// Find lowest expense transaction info
  static LowestExpenseInfo? _findLowestExpenseInfo(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return null;

    TransactionEntity? lowest;
    for (final tx in transactions) {
      if (lowest == null || tx.amount < lowest.amount) {
        lowest = tx;
      }
    }

    if (lowest == null) return null;

    return LowestExpenseInfo(
      merchant: lowest.merchant,
      amount: lowest.amount,
      date: lowest.date,
      category: lowest.category,
    );
  }

  /// Detect unusual expenses (outliers)
  static List<UnusualExpense> _detectUnusualExpenses(
    List<TransactionEntity> transactions,
    ExpenseStatistics stats,
  ) {
    if (transactions.length < 3 || stats.standardDeviation == 0) {
      return [];
    }

    final unusual = <UnusualExpense>[];
    const zScoreThreshold = 2.0; // 2 standard deviations

    for (final tx in transactions) {
      final zScore = (tx.amount - stats.averageExpense) / stats.standardDeviation;

      if (zScore.abs() > zScoreThreshold) {
        String reason;
        if (zScore > zScoreThreshold) {
          reason = 'Significantly higher than average (${(zScore).toStringAsFixed(1)}σ)';
        } else {
          reason = 'Significantly lower than average (${(zScore).toStringAsFixed(1)}σ)';
        }

        unusual.add(UnusualExpense(
          merchant: tx.merchant,
          amount: tx.amount,
          date: tx.date,
          category: tx.category,
          zScore: zScore,
          reason: reason,
        ));
      }
    }

    return unusual..sort((a, b) => b.zScore.abs().compareTo(a.zScore.abs()));
  }

  /// Detect recurring expense patterns
  static List<RecurringExpensePattern> _detectRecurringPatterns(
    List<TransactionEntity> allTransactions,
  ) {
    if (allTransactions.isEmpty) return [];

    final patterns = <String, List<TransactionEntity>>{};
    for (final tx in allTransactions) {
      final key = '${tx.merchant}|${tx.category}';
      patterns.putIfAbsent(key, () => []).add(tx);
    }

    final recurringPatterns = <RecurringExpensePattern>[];

    for (final entry in patterns.entries) {
      final transactions = entry.value;
      if (transactions.length >= 2) {
        final amounts = transactions.map((t) => t.amount).toList();
        final avgAmount = amounts.fold(0.0, (sum, a) => sum + a) / amounts.length;

        // Calculate frequency
        final gaps = <int>[];
        for (int i = 1; i < transactions.length; i++) {
          gaps.add(transactions[i].date.difference(transactions[i - 1].date).inDays);
        }

        if (gaps.isNotEmpty) {
          final avgGap = gaps.fold(0, (sum, g) => sum + g) ~/ gaps.length;
          final confidence = _calculateFrequencyConfidence(gaps);

          if (confidence >= 40) {
            final nextExpected = transactions.last.date.add(Duration(days: avgGap));
            final merchantAndCategory = entry.key.split('|');

            recurringPatterns.add(RecurringExpensePattern(
              merchant: merchantAndCategory[0],
              category: merchantAndCategory[1],
              averageAmount: avgAmount,
              frequency: avgGap,
              nextExpected: nextExpected,
              confidence: confidence,
            ));
          }
        }
      }
    }

    return recurringPatterns;
  }

  /// Calculate expense health score
  static ExpenseHealthScore _calculateHealthScore(
    ExpenseStatistics stats,
    ExpensePeriodComparison comparison,
    List<RecurringExpensePattern> recurringPatterns,
  ) {
    if (stats.expenseCount == 0) {
      return const ExpenseHealthScore(
        score: 0,
        grade: 'F',
        status: 'Critical',
        recommendation: 'No expense data available',
        insights: [],
      );
    }

    double score = 100.0;
    final insights = <String>[];

    // Deduct for high growth
    if (comparison.growthPercentage > 15) {
      score -= 20;
      insights.add('Expenses increased significantly (${comparison.growthPercentage.toStringAsFixed(1)}%)');
    } else if (comparison.growthPercentage > 5) {
      score -= 10;
    } else if (comparison.growthPercentage < -10) {
      score += 10;
      insights.add('Good expense reduction (${(-comparison.growthPercentage).toStringAsFixed(1)}%)');
    }

    // Deduct for high variability
    if (stats.standardDeviation > stats.averageExpense) {
      score -= 15;
      insights.add('Highly variable spending pattern');
    }

    // Bonus for recurring expenses
    if (recurringPatterns.isNotEmpty) {
      score += 5;
      insights.add('${recurringPatterns.length} recurring expense patterns detected');
    }

    // Ensure score is within bounds
    score = max(0, min(100, score));

    // Determine grade and status
    final (grade, status) = _getGradeAndStatus(score);
    final recommendation = _getHealthRecommendation(score, insights);

    return ExpenseHealthScore(
      score: score,
      grade: grade,
      status: status,
      recommendation: recommendation,
      insights: insights,
    );
  }

  /// Build heatmap data
  static List<SpendingHeatmapData> _buildHeatmapData(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return [];

    final dailyExpenses = <DateTime, double>{};
    for (final tx in transactions) {
      final dayKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      dailyExpenses[dayKey] = (dailyExpenses[dayKey] ?? 0) + tx.amount;
    }

    final maxAmount = dailyExpenses.values.reduce((a, b) => max(a, b));

    return dailyExpenses.entries
        .map((e) => SpendingHeatmapData(
              date: e.key,
              amount: e.value,
              intensity: ((e.value / maxAmount) * 10).toInt(),
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
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
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        final endDate = DateTime(now.year, now.month, now.day);
        return transactions.where((tx) => !tx.date.isBefore(startDate) && tx.date.isBefore(endDate)).toList();
      case '7days':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '30days':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'thisMonth':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'lastMonth':
        final lastMonth = DateTime(now.year, now.month - 1);
        startDate = DateTime(lastMonth.year, lastMonth.month, 1);
        final endDate = DateTime(now.year, now.month, 1);
        return transactions.where((tx) => !tx.date.isBefore(startDate) && tx.date.isBefore(endDate)).toList();
      case 'quarter':
        final quarter = (now.month - 1) ~/ 3;
        startDate = DateTime(now.year, quarter * 3 + 1, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(const Duration(days: 30));
    }

    return transactions.where((tx) => !tx.date.isBefore(startDate)).toList();
  }

  /// Get transactions from previous period for comparison
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
      case 'yesterday':
        final twoDaysAgo = now.subtract(const Duration(days: 2));
        startDate = DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day);
        final yesterday = now.subtract(const Duration(days: 1));
        endDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        break;
      case '7days':
        startDate = now.subtract(const Duration(days: 14));
        endDate = now.subtract(const Duration(days: 7));
        break;
      case '30days':
        startDate = now.subtract(const Duration(days: 60));
        endDate = now.subtract(const Duration(days: 30));
        break;
      case 'thisMonth':
        final lastMonth = DateTime(now.year, now.month - 1);
        startDate = DateTime(lastMonth.year, lastMonth.month, 1);
        endDate = DateTime(now.year, now.month, 1);
        break;
      case 'lastMonth':
        final twoMonthsAgo = DateTime(now.year, now.month - 2);
        startDate = DateTime(twoMonthsAgo.year, twoMonthsAgo.month, 1);
        final lastMonth = DateTime(now.year, now.month - 1);
        endDate = DateTime(lastMonth.year, lastMonth.month, 1);
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
        startDate = now.subtract(const Duration(days: 60));
        endDate = now.subtract(const Duration(days: 30));
    }

    return transactions.where((tx) => !tx.date.isBefore(startDate) && tx.date.isBefore(endDate)).toList();
  }

  /// Helper: Calculate median
  static double _calculateMedian(List<double> values) {
    if (values.isEmpty) return 0;
    final sorted = List<double>.from(values)..sort();
    if (sorted.length % 2 == 0) {
      return (sorted[sorted.length ~/ 2 - 1] + sorted[sorted.length ~/ 2]) / 2;
    }
    return sorted[sorted.length ~/ 2];
  }

  /// Helper: Calculate standard deviation
  static double _calculateStandardDeviation(List<double> values, double mean) {
    if (values.length < 2) return 0;
    final variance = values.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / values.length;
    return sqrt(variance);
  }

  /// Helper: Get top category for a day
  static String _getTopCategory(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return 'Other';
    final categoryMap = <String, double>{};
    for (final tx in transactions) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
    }
    return categoryMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Helper: Calculate frequency confidence
  static int _calculateFrequencyConfidence(List<int> gaps) {
    if (gaps.isEmpty) return 0;
    final mean = gaps.fold(0, (sum, g) => sum + g) / gaps.length;
    if (mean == 0) return 0;
    final variance = gaps.map((g) => (g - mean) * (g - mean)).fold(0.0, (sum, v) => sum + v) / gaps.length;
    final stdDev = sqrt(variance);
    final coefficientOfVariation = stdDev / mean;
    if (coefficientOfVariation.isNaN || coefficientOfVariation.isInfinite) return 0;
    // Convert CV to confidence (lower variation = higher confidence)
    return max(0, min(100, (100 * (1 - coefficientOfVariation)).toInt()));
  }

  /// Helper: Get grade and status
  static (String, String) _getGradeAndStatus(double score) {
    if (score >= 95) return ('A+', 'Excellent');
    if (score >= 90) return ('A', 'Excellent');
    if (score >= 85) return ('B+', 'Good');
    if (score >= 80) return ('B', 'Good');
    if (score >= 70) return ('C+', 'Fair');
    if (score >= 60) return ('C', 'Fair');
    if (score >= 40) return ('D', 'Poor');
    return ('F', 'Critical');
  }

  /// Helper: Get health recommendation
  static String _getHealthRecommendation(double score, List<String> insights) {
    if (score >= 80) {
      return 'Your spending is well-controlled. Keep up the good habits!';
    } else if (score >= 60) {
      return 'Your spending is moderate. Look for opportunities to optimize.';
    } else if (score >= 40) {
      return 'Your spending is above average. Consider reviewing your budget.';
    } else {
      return 'Your spending is high. Urgent action needed to control expenses.';
    }
  }
}
