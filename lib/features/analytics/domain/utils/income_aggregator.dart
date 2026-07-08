import 'dart:math';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/income_data.dart';

class IncomeAggregator {
  /// Aggregate income data based on time filter
  static IncomeReport aggregate({
    required List<TransactionEntity> transactions,
    required String timeFilter,
  }) {
    // Filter transactions to income only and not deleted
    final allIncomeTx = transactions
        .where((tx) => !tx.isDeleted && tx.type == 'income')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Get filtered transactions based on time filter
    final filteredTx = _filterByTimeFrame(allIncomeTx, timeFilter);
    final previousTx = _getPreviousPeriod(allIncomeTx, timeFilter);

    if (filteredTx.isEmpty) {
      return IncomeReport.empty();
    }

    // Calculate basic statistics
    final statistics = _calculateStatistics(filteredTx);
    final comparison = _calculateComparison(filteredTx, previousTx);

    // Build data points for chart
    final points = _buildIncomePoints(filteredTx);

    // Build category distribution
    final categories = _buildCategoryDistribution(filteredTx, statistics.totalIncome);

    // Build source distribution
    final sources = _buildSourceDistribution(filteredTx);

    // Build calendar data
    final calendarData = _buildCalendarData(filteredTx);

    // Find largest and smallest income info
    final largestIncomeInfo = _findLargestIncomeInfo(filteredTx);
    final smallestIncomeInfo = _findSmallestIncomeInfo(filteredTx);

    return IncomeReport(
      totalIncome: statistics.totalIncome,
      growthPercentage: comparison.growthPercentage,
      averageIncome: statistics.averageIncome,
      largestIncome: statistics.largestIncome,
      smallestIncome: statistics.smallestIncome,
      incomeCount: statistics.incomeCount,
      largestIncomeInfo: largestIncomeInfo,
      smallestIncomeInfo: smallestIncomeInfo,
      points: points,
      categories: categories,
      sources: sources,
      statistics: statistics,
      comparison: comparison,
      calendarData: calendarData,
    );
  }

  /// Calculate detailed income statistics
  static IncomeStatistics _calculateStatistics(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return IncomeStatistics.empty();
    }

    double total = 0.0;
    double largest = 0.0;
    double smallest = double.infinity;
    final Set<DateTime> daysSet = {};

    for (final tx in transactions) {
      total += tx.amount;
      largest = max(largest, tx.amount);
      smallest = min(smallest, tx.amount);
      daysSet.add(DateTime(tx.date.year, tx.date.month, tx.date.day));
    }

    final average = total / transactions.length;
    final daysSpan = max(1, daysSet.length);
    final averagePerDay = total / daysSpan;
    final averagePerWeek = averagePerDay * 7;
    final averagePerMonth = averagePerDay * 30;

    return IncomeStatistics(
      totalIncome: total,
      averageIncome: average,
      largestIncome: largest,
      smallestIncome: smallest == double.infinity ? 0.0 : smallest,
      incomeCount: transactions.length,
      averagePerDay: averagePerDay,
      averagePerWeek: averagePerWeek,
      averagePerMonth: averagePerMonth,
    );
  }

  /// Calculate period comparison
  static PeriodComparison _calculateComparison(
    List<TransactionEntity> currentPeriod,
    List<TransactionEntity> previousPeriod,
  ) {
    double currentTotal = currentPeriod.fold(0.0, (sum, tx) => sum + tx.amount);
    double previousTotal = previousPeriod.fold(0.0, (sum, tx) => sum + tx.amount);

    double growthPercentage = 0.0;
    if (previousTotal > 0) {
      growthPercentage = ((currentTotal - previousTotal) / previousTotal) * 100;
    }

    return PeriodComparison(
      currentPeriodIncome: currentTotal,
      previousPeriodIncome: previousTotal,
      growthPercentage: growthPercentage,
      isIncrease: growthPercentage >= 0,
    );
  }

  /// Build income points for chart visualization
  static List<IncomePoint> _buildIncomePoints(List<TransactionEntity> transactions) {
    final points = <IncomePoint>[];
    double runningTotal = 0.0;

    for (final tx in transactions) {
      runningTotal += tx.amount;
      points.add(IncomePoint(
        date: tx.date,
        amount: tx.amount,
        runningTotal: runningTotal,
      ));
    }

    return points;
  }

  /// Build category distribution
  static List<CategorySlice> _buildCategoryDistribution(
    List<TransactionEntity> transactions,
    double total,
  ) {
    final categoryMap = <String, double>{};

    for (final tx in transactions) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0.0) + tx.amount;
    }

    return categoryMap.entries
        .map((e) => CategorySlice(
              categoryName: e.key,
              amount: e.value,
              percentage: total > 0 ? (e.value / total) * 100 : 0.0,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  /// Build source distribution
  static List<SourceSlice> _buildSourceDistribution(List<TransactionEntity> transactions) {
    final sourceMap = <String, double>{};

    for (final tx in transactions) {
      sourceMap[tx.paymentMethod] = (sourceMap[tx.paymentMethod] ?? 0.0) + tx.amount;
    }

    return sourceMap.entries
        .map((e) => SourceSlice(
              sourceName: e.key,
              amount: e.value,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  /// Build calendar data
  static List<IncomeCalendarDay> _buildCalendarData(List<TransactionEntity> transactions) {
    final dateMap = <DateTime, List<TransactionEntity>>{};

    for (final tx in transactions) {
      final dayKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      dateMap.putIfAbsent(dayKey, () => []).add(tx);
    }

    return dateMap.entries
        .map((e) {
          final dayTotal = e.value.fold(0.0, (sum, tx) => sum + tx.amount);
          return IncomeCalendarDay(
            date: e.key,
            totalIncome: dayTotal,
            incomeCount: e.value.length,
          );
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Find largest income transaction info
  static LargestIncomeInfo? _findLargestIncomeInfo(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return null;

    TransactionEntity? largest;
    for (final tx in transactions) {
      if (largest == null || tx.amount > largest.amount) {
        largest = tx;
      }
    }

    if (largest == null) return null;

    return LargestIncomeInfo(
      merchant: largest.merchant,
      amount: largest.amount,
      date: largest.date,
      category: largest.category,
    );
  }

  /// Find smallest income transaction info
  static SmallestIncomeInfo? _findSmallestIncomeInfo(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return null;

    TransactionEntity? smallest;
    for (final tx in transactions) {
      if (smallest == null || tx.amount < smallest.amount) {
        smallest = tx;
      }
    }

    if (smallest == null) return null;

    return SmallestIncomeInfo(
      merchant: smallest.merchant,
      amount: smallest.amount,
      date: smallest.date,
      category: smallest.category,
    );
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
      case 'thisQuarter':
        final quarter = (now.month - 1) ~/ 3;
        startDate = DateTime(now.year, quarter * 3 + 1, 1);
        break;
      case 'thisYear':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        // Default to last 30 days
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
      case 'thisQuarter':
        final quarter = (now.month - 1) ~/ 3;
        final lastQuarter = (quarter - 1 + 4) % 4;
        startDate = DateTime(now.year, lastQuarter * 3 + 1, 1);
        endDate = DateTime(now.year, quarter * 3 + 1, 1);
        break;
      case 'thisYear':
        startDate = DateTime(now.year - 1, 1, 1);
        endDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(const Duration(days: 60));
        endDate = now.subtract(const Duration(days: 30));
    }

    return transactions.where((tx) => !tx.date.isBefore(startDate) && tx.date.isBefore(endDate)).toList();
  }
}
