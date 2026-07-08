import 'dart:math';

import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/weekly_report_data.dart';
import 'weekly_comparison_service.dart';

class WeeklyAggregator {
  const WeeklyAggregator._();

  static WeeklyReport aggregate({
    required List<TransactionEntity> transactions,
    required DateTime weekAnchor,
  }) {
    final weekStart = _weekStart(weekAnchor);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final previousStart = weekStart.subtract(const Duration(days: 7));
    final active = transactions.where((tx) => !tx.isDeleted).toList();
    final currentWeek = _between(active, weekStart, weekEnd);
    final previousWeek = _between(active, previousStart, weekStart);

    final summary = _summary(currentWeek);
    final previousSummary = _summary(previousWeek);
    final dailyBreakdown = _dailyBreakdown(currentWeek, weekStart);
    final statistics = _statistics(currentWeek, dailyBreakdown);
    final categories = _categories(currentWeek, summary.expense);
    final timeline = _timeline(currentWeek);
    final comparison = WeeklyComparisonService.compare(
      current: summary,
      previous: previousSummary,
    );
    final score = _score(summary);

    return WeeklyReport(
      weekStart: weekStart,
      weekEnd: weekEnd.subtract(const Duration(days: 1)),
      summary: summary,
      statistics: statistics,
      categories: categories,
      dailyBreakdown: dailyBreakdown,
      timeline: timeline,
      comparison: comparison,
      score: score,
      recommendations: _recommendations(summary, comparison, dailyBreakdown),
      exportHooks: WeeklyReportExportHooks.enabled(),
    );
  }

  static WeeklySummary _summary(List<TransactionEntity> transactions) {
    double income = 0;
    double expense = 0;
    for (final tx in transactions) {
      if (tx.type == 'income') income += tx.amount;
      if (tx.type == 'expense') expense += tx.amount;
    }
    return WeeklySummary(
      income: income,
      expense: expense,
      savings: income - expense,
      cashFlow: income - expense,
    );
  }

  static WeeklyStatistics _statistics(
    List<TransactionEntity> transactions,
    List<WeeklyDayBreakdown> days,
  ) {
    final incomeTx = transactions.where((tx) => tx.type == 'income').toList();
    final expenseTx = transactions.where((tx) => tx.type == 'expense').toList();
    final totalAmount = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
    final largestExpense = expenseTx.isEmpty
        ? 0.0
        : expenseTx.map((tx) => tx.amount).reduce(max);
    final largestIncome = incomeTx.isEmpty
        ? 0.0
        : incomeTx.map((tx) => tx.amount).reduce(max);
    final activeDays = days.where((day) => day.transactionCount > 0).toList();

    return WeeklyStatistics(
      totalTransactions: transactions.length,
      incomeTransactions: incomeTx.length,
      expenseTransactions: expenseTx.length,
      averageDailyExpense:
          days.fold<double>(0, (sum, day) => sum + day.expense) / 7,
      averageDailyIncome:
          days.fold<double>(0, (sum, day) => sum + day.income) / 7,
      averageTransaction:
          transactions.isEmpty ? 0 : totalAmount / transactions.length,
      largestExpense: largestExpense,
      largestIncome: largestIncome,
      mostActiveDay: activeDays.isEmpty
          ? null
          : activeDays.reduce(
              (a, b) => a.transactionCount >= b.transactionCount ? a : b,
            ),
      leastActiveDay: days.reduce(
        (a, b) => a.transactionCount <= b.transactionCount ? a : b,
      ),
    );
  }

  static List<WeeklyDayBreakdown> _dailyBreakdown(
    List<TransactionEntity> transactions,
    DateTime weekStart,
  ) {
    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      final daily = transactions.where((tx) => _sameDay(tx.date, date)).toList();
      final summary = _summary(daily);
      return WeeklyDayBreakdown(
        date: date,
        weekday: _weekdayName(date.weekday),
        income: summary.income,
        expense: summary.expense,
        savings: summary.savings,
        transactionCount: daily.length,
      );
    });
  }

  static List<WeeklyCategoryBreakdown> _categories(
    List<TransactionEntity> transactions,
    double totalExpense,
  ) {
    final grouped = <String, (double, int)>{};
    for (final tx in transactions.where((tx) => tx.type == 'expense')) {
      final existing = grouped[tx.category] ?? (0.0, 0);
      grouped[tx.category] = (existing.$1 + tx.amount, existing.$2 + 1);
    }
    final categories = grouped.entries.map((entry) {
      return WeeklyCategoryBreakdown(
        category: entry.key,
        amount: entry.value.$1,
        percentage:
            totalExpense > 0 ? (entry.value.$1 / totalExpense) * 100 : 0,
        transactionCount: entry.value.$2,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return categories;
  }

  static List<WeeklyTransactionItem> _timeline(
    List<TransactionEntity> transactions,
  ) {
    final sorted = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted.map((tx) {
      return WeeklyTransactionItem(
        id: tx.uuid,
        date: tx.date,
        title: tx.title,
        type: tx.type,
        category: tx.category,
        amount: tx.amount,
      );
    }).toList();
  }

  static WeeklyScore _score(WeeklySummary summary) {
    var score = 50.0;
    final factors = <String>[];
    final totalIncome = summary.income;
    final expenseRatio = totalIncome <= 0 ? 1.0 : summary.expense / totalIncome;

    if (summary.cashFlow > 0) {
      score += 20;
      factors.add('Positive weekly cash flow');
    } else if (summary.cashFlow < 0) {
      score -= 20;
      factors.add('Negative weekly cash flow');
    }

    if (expenseRatio <= 0.5) {
      score += 20;
      factors.add('Expense ratio below 50%');
    } else if (expenseRatio > 0.9) {
      score -= 15;
      factors.add('High expense ratio');
    }

    if (summary.savings > 0) {
      score += 10;
      factors.add('Weekly savings generated');
    }

    score = score.clamp(0, 100);
    return WeeklyScore(
      score: score,
      grade: _grade(score),
      status: _status(score),
      factors: factors,
    );
  }

  static List<String> _recommendations(
    WeeklySummary summary,
    WeeklyComparison comparison,
    List<WeeklyDayBreakdown> days,
  ) {
    final recommendations = <String>[];
    if (comparison.expenseGrowthPercentage < 0) {
      recommendations.add(
        'Your spending reduced ${comparison.expenseGrowthPercentage.abs().toStringAsFixed(1)}% compared to last week.',
      );
    } else if (comparison.expenseGrowthPercentage > 0) {
      recommendations.add(
        'Your spending increased ${comparison.expenseGrowthPercentage.toStringAsFixed(1)}% compared to last week.',
      );
    }
    if (summary.savings > 0) {
      recommendations.add(
        'You saved ${summary.savings.toStringAsFixed(0)} this week.',
      );
    }

    final weekendExpense = days
        .where((day) =>
            day.date.weekday == DateTime.saturday ||
            day.date.weekday == DateTime.sunday)
        .fold<double>(0, (sum, day) => sum + day.expense);
    final weekdayExpense = days
        .where((day) =>
            day.date.weekday != DateTime.saturday &&
            day.date.weekday != DateTime.sunday)
        .fold<double>(0, (sum, day) => sum + day.expense);
    if (weekendExpense > weekdayExpense && weekendExpense > 0) {
      recommendations.add('Weekend spending was higher than weekdays.');
    }

    return recommendations;
  }

  static List<TransactionEntity> _between(
    List<TransactionEntity> transactions,
    DateTime start,
    DateTime end,
  ) {
    return transactions
        .where((tx) => !tx.date.isBefore(start) && tx.date.isBefore(end))
        .toList();
  }

  static DateTime _weekStart(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static bool _sameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday - 1];
  }

  static String _grade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  static String _status(double score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 55) return 'Fair';
    return 'Needs Attention';
  }
}
