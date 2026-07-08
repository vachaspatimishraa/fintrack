import 'dart:math';

import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/spending_trend_data.dart';
import 'momentum_calculator.dart';
import 'moving_average_calculator.dart';
import 'trend_comparison_service.dart';
import 'velocity_calculator.dart';

class TrendEngine {
  const TrendEngine._();

  static SpendingTrendReport aggregate({
    required List<TransactionEntity> transactions,
    required String timeFilter,
    TrendGranularity granularity = TrendGranularity.daily,
  }) {
    final expenseTransactions = transactions
        .where((tx) => !tx.isDeleted && tx.type == 'expense')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final filtered = _filterByTimeFrame(expenseTransactions, timeFilter);
    if (filtered.isEmpty) {
      return SpendingTrendReport.empty(granularity: granularity);
    }

    final previous = _getPreviousPeriod(expenseTransactions, timeFilter);
    final bucketed = _bucketTransactions(filtered, granularity);
    final previousBucketed = _bucketTransactions(previous, granularity);
    final amounts = bucketed.values.map((bucket) => bucket.amount).toList();
    final averages = MovingAverageCalculator.calculate(amounts);
    final points = <SpendingTrendPoint>[];

    var index = 0;
    double previousAmount = 0;
    for (final entry in bucketed.entries) {
      final bucket = entry.value;
      final growth = TrendComparisonService.growthPercentage(
        bucket.amount,
        previousAmount,
      );
      points.add(
        SpendingTrendPoint(
          periodStart: bucket.start,
          periodEnd: bucket.end,
          amount: bucket.amount,
          previousAmount: previousAmount,
          difference: VelocityCalculator.calculate(bucket.amount, previousAmount),
          growthPercentage: growth,
          movingAverage: averages[index],
          transactionCount: bucket.count,
          direction: TrendComparisonService.directionFor(growth),
        ),
      );
      previousAmount = bucket.amount;
      index++;
    }

    final currentTotal = filtered.fold<double>(0, (sum, tx) => sum + tx.amount);
    final previousTotal = previous.fold<double>(0, (sum, tx) => sum + tx.amount);
    final totalGrowth = TrendComparisonService.growthPercentage(
      currentTotal,
      previousTotal,
    );
    final valuesForMomentum = points.map((point) => point.amount).toList();
    final velocity = VelocityCalculator.calculate(currentTotal, previousTotal);
    final summary = TrendSummary(
      currentSpending: currentTotal,
      previousSpending: previousTotal,
      growthPercentage: totalGrowth,
      velocity: velocity,
      momentum: MomentumCalculator.calculate(valuesForMomentum),
      confidence: MomentumCalculator.confidence(valuesForMomentum),
      direction: TrendComparisonService.directionFor(totalGrowth),
      description: _describeTrend(totalGrowth),
    );

    return SpendingTrendReport(
      totalSpending: currentTotal,
      transactionCount: filtered.length,
      granularity: granularity,
      summary: summary,
      points: points,
      peakPeriods: _periodInsights(points, descending: true),
      lowPeriods: _periodInsights(points, descending: false),
      comparisons: [
        TrendComparisonService.compare(
          label: _comparisonLabel(timeFilter),
          current: currentTotal,
          previous: previousTotal,
        ),
        TrendComparisonService.compare(
          label: 'Average Period',
          current: points.isEmpty ? 0 : currentTotal / points.length,
          previous: previousBucketed.isEmpty
              ? 0
              : previousTotal / previousBucketed.length,
        ),
      ],
      forecast: _forecast(points),
      habits: _detectHabits(filtered, points),
    );
  }

  static SpendingTrendReport getDailyTrend(List<TransactionEntity> transactions) {
    return aggregate(
      transactions: transactions,
      timeFilter: 'month',
      granularity: TrendGranularity.daily,
    );
  }

  static SpendingTrendReport getWeeklyTrend(List<TransactionEntity> transactions) {
    return aggregate(
      transactions: transactions,
      timeFilter: 'year',
      granularity: TrendGranularity.weekly,
    );
  }

  static SpendingTrendReport getMonthlyTrend(List<TransactionEntity> transactions) {
    return aggregate(
      transactions: transactions,
      timeFilter: 'year',
      granularity: TrendGranularity.monthly,
    );
  }

  static SpendingTrendReport getYearlyTrend(List<TransactionEntity> transactions) {
    return aggregate(
      transactions: transactions,
      timeFilter: 'all',
      granularity: TrendGranularity.yearly,
    );
  }

  static Map<DateTime, _TrendBucket> _bucketTransactions(
    List<TransactionEntity> transactions,
    TrendGranularity granularity,
  ) {
    final buckets = <DateTime, _TrendBucket>{};
    for (final tx in transactions) {
      final start = _bucketStart(tx.date, granularity);
      final end = _bucketEnd(start, granularity);
      final current = buckets[start] ?? _TrendBucket(start: start, end: end);
      buckets[start] = current.add(tx.amount);
    }
    return Map.fromEntries(
      buckets.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  static List<TransactionEntity> _filterByTimeFrame(
    List<TransactionEntity> transactions,
    String timeFilter,
  ) {
    final now = DateTime.now();
    DateTime? start;

    switch (timeFilter) {
      case 'today':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
      case '7days':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'month':
      case '30days':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'quarter':
        final quarter = (now.month - 1) ~/ 3;
        start = DateTime(now.year, quarter * 3 + 1, 1);
        break;
      case 'year':
        start = DateTime(now.year, 1, 1);
        break;
      case 'all':
        start = null;
        break;
      default:
        start = DateTime(now.year, now.month, 1);
    }

    if (start == null) return transactions;
    return transactions.where((tx) => !tx.date.isBefore(start!)).toList();
  }

  static List<TransactionEntity> _getPreviousPeriod(
    List<TransactionEntity> transactions,
    String timeFilter,
  ) {
    final now = DateTime.now();
    late DateTime start;
    late DateTime end;

    switch (timeFilter) {
      case 'today':
        final yesterday = now.subtract(const Duration(days: 1));
        start = DateTime(yesterday.year, yesterday.month, yesterday.day);
        end = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
      case '7days':
        start = now.subtract(const Duration(days: 14));
        end = now.subtract(const Duration(days: 7));
        break;
      case 'month':
      case '30days':
        final lastMonth = DateTime(now.year, now.month - 1);
        start = DateTime(lastMonth.year, lastMonth.month, 1);
        end = DateTime(now.year, now.month, 1);
        break;
      case 'quarter':
        final quarter = (now.month - 1) ~/ 3;
        final currentQuarterStart = DateTime(now.year, quarter * 3 + 1, 1);
        start = DateTime(
          currentQuarterStart.month == 1 ? now.year - 1 : now.year,
          currentQuarterStart.month == 1 ? 10 : currentQuarterStart.month - 3,
          1,
        );
        end = currentQuarterStart;
        break;
      case 'year':
        start = DateTime(now.year - 1, 1, 1);
        end = DateTime(now.year, 1, 1);
        break;
      default:
        start = now.subtract(const Duration(days: 60));
        end = now.subtract(const Duration(days: 30));
    }

    return transactions
        .where((tx) => !tx.date.isBefore(start) && tx.date.isBefore(end))
        .toList();
  }

  static DateTime _bucketStart(DateTime date, TrendGranularity granularity) {
    switch (granularity) {
      case TrendGranularity.daily:
        return DateTime(date.year, date.month, date.day);
      case TrendGranularity.weekly:
        final day = DateTime(date.year, date.month, date.day);
        return day.subtract(Duration(days: day.weekday - 1));
      case TrendGranularity.monthly:
        return DateTime(date.year, date.month, 1);
      case TrendGranularity.yearly:
        return DateTime(date.year, 1, 1);
    }
  }

  static DateTime _bucketEnd(DateTime start, TrendGranularity granularity) {
    switch (granularity) {
      case TrendGranularity.daily:
        return start.add(const Duration(days: 1));
      case TrendGranularity.weekly:
        return start.add(const Duration(days: 7));
      case TrendGranularity.monthly:
        return DateTime(start.year, start.month + 1, 1);
      case TrendGranularity.yearly:
        return DateTime(start.year + 1, 1, 1);
    }
  }

  static List<SpendingPeriodInsight> _periodInsights(
    List<SpendingTrendPoint> points, {
    required bool descending,
  }) {
    final sorted = List<SpendingTrendPoint>.from(points)
      ..sort((a, b) => descending
          ? b.amount.compareTo(a.amount)
          : a.amount.compareTo(b.amount));
    return sorted.take(3).map((point) {
      return SpendingPeriodInsight(
        label: _formatPeriod(point.periodStart, point.periodEnd),
        periodStart: point.periodStart,
        periodEnd: point.periodEnd,
        amount: point.amount,
        transactionCount: point.transactionCount,
      );
    }).toList();
  }

  static SpendingForecast _forecast(List<SpendingTrendPoint> points) {
    if (points.isEmpty) return SpendingForecast.empty();
    final values = points.map((point) => point.amount).toList();
    final latestAverage = MovingAverageCalculator.latest(values);
    final momentum = MomentumCalculator.calculate(values);
    final expected = max(0.0, latestAverage + momentum);
    final last = points.last;
    final span = last.periodEnd.difference(last.periodStart);
    return SpendingForecast(
      periodStart: last.periodEnd,
      periodEnd: last.periodEnd.add(span),
      expectedSpending: expected,
      confidenceScore: MomentumCalculator.confidence(values),
      direction: TrendComparisonService.directionFor(
        TrendComparisonService.growthPercentage(expected, last.amount),
      ),
    );
  }

  static SpendingHabitIndicators _detectHabits(
    List<TransactionEntity> transactions,
    List<SpendingTrendPoint> points,
  ) {
    final recommendations = <String>[];
    final values = points.map((point) => point.amount).toList();
    final regularSpending = MomentumCalculator.confidence(values) >= 0.65;
    final impulseSpending = values.isNotEmpty &&
        points.any((point) => point.amount > MovingAverageCalculator.latest(values) * 1.75);

    final weekendTotal = transactions
        .where((tx) => tx.date.weekday == DateTime.saturday || tx.date.weekday == DateTime.sunday)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final weekdayTotal = transactions
        .where((tx) => tx.date.weekday != DateTime.saturday && tx.date.weekday != DateTime.sunday)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final weekendPeaks = weekendTotal > weekdayTotal && weekendTotal > 0;
    final salaryDaySpending = transactions.any((tx) => tx.date.day <= 3);
    final subscriptionPatterns = _hasRecurringPattern(transactions);

    if (regularSpending) {
      recommendations.add('Your average spending is stabilizing.');
    }
    if (impulseSpending) {
      recommendations.add('A few periods are far above your usual spending.');
    }
    if (weekendPeaks) {
      recommendations.add('Weekend spending is consistently higher.');
    }

    return SpendingHabitIndicators(
      regularSpending: regularSpending,
      impulseSpending: impulseSpending,
      weekendPeaks: weekendPeaks,
      salaryDaySpending: salaryDaySpending,
      subscriptionPatterns: subscriptionPatterns,
      recommendations: recommendations,
    );
  }

  static bool _hasRecurringPattern(List<TransactionEntity> transactions) {
    final byTitle = <String, int>{};
    for (final tx in transactions) {
      if (tx.title.isEmpty) continue;
      byTitle[tx.title] = (byTitle[tx.title] ?? 0) + 1;
    }
    return byTitle.values.any((count) => count >= 3);
  }

  static String _describeTrend(double growth) {
    if (growth > 5) return 'User spending is rising.';
    if (growth < -5) return 'User spending is decreasing.';
    return 'Minimal variation in spending.';
  }

  static String _comparisonLabel(String timeFilter) {
    switch (timeFilter) {
      case 'today':
        return 'Today vs Yesterday';
      case 'week':
      case '7days':
        return 'Week vs Last Week';
      case 'month':
      case '30days':
        return 'Month vs Last Month';
      case 'year':
        return 'Year vs Last Year';
      default:
        return 'Current vs Previous';
    }
  }

  static String _formatPeriod(DateTime start, DateTime end) {
    if (end.difference(start).inDays <= 1) {
      return '${start.day}/${start.month}/${start.year}';
    }
    return '${start.day}/${start.month} - ${end.subtract(const Duration(days: 1)).day}/${end.subtract(const Duration(days: 1)).month}';
  }
}

class _TrendBucket {
  final DateTime start;
  final DateTime end;
  final double amount;
  final int count;

  const _TrendBucket({
    required this.start,
    required this.end,
    this.amount = 0,
    this.count = 0,
  });

  _TrendBucket add(double value) {
    return _TrendBucket(
      start: start,
      end: end,
      amount: amount + value,
      count: count + 1,
    );
  }
}
