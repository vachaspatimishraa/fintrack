import 'dart:math';

import '../../../budget/domain/entities/budget_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/monthly_report_data.dart';
import 'monthly_analytics_engine.dart';
import 'monthly_comparison_service.dart';

class MonthlyAggregator {
  const MonthlyAggregator._();

  static MonthlyReport aggregate({
    required List<TransactionEntity> transactions,
    required List<BudgetEntity> budgets,
    required DateTime monthAnchor,
  }) {
    final monthStart = DateTime(monthAnchor.year, monthAnchor.month, 1);
    final monthEnd = DateTime(monthAnchor.year, monthAnchor.month + 1, 1).subtract(const Duration(days: 1));

    final prevMonthAnchor = DateTime(monthAnchor.year, monthAnchor.month - 1, 1);
    final prevMonthStart = DateTime(prevMonthAnchor.year, prevMonthAnchor.month, 1);
    final prevMonthEnd = DateTime(prevMonthAnchor.year, prevMonthAnchor.month + 1, 1).subtract(const Duration(days: 1));

    // Filter active transactions
    final activeTx = transactions.where((tx) => !tx.isDeleted).toList();

    final currentTx = _between(activeTx, monthStart, monthEnd.add(const Duration(days: 1)));
    final previousTx = _between(activeTx, prevMonthStart, prevMonthEnd.add(const Duration(days: 1)));

    final summary = _summary(currentTx);
    final previousSummary = _summary(previousTx);

    final dailyBreakdown = _dailyBreakdown(currentTx, monthStart, monthEnd);
    final statistics = _statistics(currentTx, dailyBreakdown);

    // Active budgets in current month
    final activeBudgets = budgets.where((b) {
      if (b.isDeleted) return false;
      return !b.startDate.isAfter(monthEnd) && !b.endDate.isBefore(monthStart);
    }).toList();

    // Active budgets in previous month
    final prevActiveBudgets = budgets.where((b) {
      if (b.isDeleted) return false;
      return !b.startDate.isAfter(prevMonthEnd) && !b.endDate.isBefore(prevMonthStart);
    }).toList();

    final budgetProgress = _budgetProgress(currentTx, activeBudgets);
    final prevBudgetProgress = _budgetProgress(previousTx, prevActiveBudgets);

    final categories = _categories(currentTx, previousTx, summary.expense);
    final timeline = _timeline(currentTx);

    final comparison = MonthlyComparisonService.compare(
      current: summary,
      previous: previousSummary,
      currentBudgetSpent: budgetProgress.spent,
      previousBudgetSpent: prevBudgetProgress.spent,
      currentTransactionsCount: currentTx.length,
      previousTransactionsCount: previousTx.length,
    );

    final score = MonthlyAnalyticsEngine.calculateScore(
      summary: summary,
      budgetProgress: budgetProgress,
    );

    final recommendations = MonthlyAnalyticsEngine.generateRecommendations(
      summary: summary,
      comparison: comparison,
      budgetProgress: budgetProgress,
      categories: categories,
    );

    return MonthlyReport(
      monthStart: monthStart,
      monthEnd: monthEnd,
      summary: summary,
      statistics: statistics,
      budgetProgress: budgetProgress,
      categories: categories,
      dailyBreakdown: dailyBreakdown,
      timeline: timeline,
      comparison: comparison,
      score: score,
      recommendations: recommendations,
      exportHooks: MonthlyReportExportHooks.enabled(),
    );
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

  static MonthlySummary _summary(List<TransactionEntity> transactions) {
    double income = 0;
    double expense = 0;
    for (final tx in transactions) {
      if (tx.type == 'income') income += tx.amount;
      if (tx.type == 'expense') expense += tx.amount;
    }
    return MonthlySummary(
      income: income,
      expense: expense,
      savings: income - expense,
      cashFlow: income - expense,
    );
  }

  static List<MonthlyDayBreakdown> _dailyBreakdown(
    List<TransactionEntity> transactions,
    DateTime monthStart,
    DateTime monthEnd,
  ) {
    final daysInMonth = monthEnd.day;
    return List.generate(daysInMonth, (index) {
      final date = monthStart.add(Duration(days: index));
      final dailyTx = transactions.where((tx) => _sameDay(tx.date, date)).toList();
      final dailySummary = _summary(dailyTx);

      return MonthlyDayBreakdown(
        date: date,
        weekday: _weekdayName(date.weekday),
        income: dailySummary.income,
        expense: dailySummary.expense,
        savings: dailySummary.savings,
        transactionCount: dailyTx.length,
      );
    });
  }

  static MonthlyStatistics _statistics(
    List<TransactionEntity> transactions,
    List<MonthlyDayBreakdown> days,
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
    final daysCount = days.isEmpty ? 1.0 : days.length.toDouble();

    final totalIncome = incomeTx.fold<double>(0, (sum, tx) => sum + tx.amount);
    final totalExpense = expenseTx.fold<double>(0, (sum, tx) => sum + tx.amount);

    return MonthlyStatistics(
      totalTransactions: transactions.length,
      incomeTransactions: incomeTx.length,
      expenseTransactions: expenseTx.length,
      averageDailyExpense: totalExpense / daysCount,
      averageDailyIncome: totalIncome / daysCount,
      averageTransaction: transactions.isEmpty ? 0.0 : totalAmount / transactions.length,
      largestExpense: largestExpense,
      largestIncome: largestIncome,
      netSavings: totalIncome - totalExpense,
      mostActiveDay: activeDays.isEmpty
          ? null
          : activeDays.reduce(
              (a, b) => a.transactionCount >= b.transactionCount ? a : b,
            ),
      leastActiveDay: days.isEmpty
          ? null
          : days.reduce(
              (a, b) => a.transactionCount <= b.transactionCount ? a : b,
            ),
    );
  }

  static MonthlyBudgetProgress _budgetProgress(
    List<TransactionEntity> transactions,
    List<BudgetEntity> activeBudgets,
  ) {
    if (activeBudgets.isEmpty) {
      return MonthlyBudgetProgress.zero();
    }

    // Determine total budgets (overall) vs category specific budgets
    final totalBudgets = activeBudgets.where((b) => b.categoryId == null || b.budgetType == 'total').toList();
    final categoryBudgets = activeBudgets.where((b) => b.categoryId != null && b.budgetType == 'category').toList();

    double budgetLimit = 0.0;
    double spent = 0.0;

    if (totalBudgets.isNotEmpty) {
      budgetLimit = totalBudgets.fold<double>(0, (sum, b) => sum + b.amount);
      // Spent is the sum of all expenses in the month
      spent = transactions
          .where((tx) => tx.type == 'expense')
          .fold<double>(0, (sum, tx) => sum + tx.amount);
    } else {
      // Sum category budgets as overall fallback limit
      budgetLimit = activeBudgets.fold<double>(0, (sum, b) => sum + b.amount);
      spent = transactions
          .where((tx) => tx.type == 'expense')
          .fold<double>(0, (sum, tx) => sum + tx.amount);
    }

    final exceededCategories = <String>[];
    final safeCategories = <String>[];

    for (final cb in categoryBudgets) {
      final catExpense = transactions
          .where((tx) => tx.type == 'expense' && (tx.categoryId == cb.categoryId || tx.category == cb.title))
          .fold<double>(0, (sum, tx) => sum + tx.amount);

      if (catExpense > cb.amount) {
        exceededCategories.add(cb.title);
      } else {
        safeCategories.add(cb.title);
      }
    }

    final utilization = budgetLimit > 0 ? spent / budgetLimit : 0.0;
    String status = 'Safe';
    if (utilization > 1.0) {
      status = 'Exceeded';
    } else if (utilization > 0.9) {
      status = 'Critical';
    } else if (utilization > 0.8) {
      status = 'Warning';
    }

    return MonthlyBudgetProgress(
      budgetLimit: budgetLimit,
      spent: spent,
      remaining: max(0.0, budgetLimit - spent),
      utilization: utilization,
      status: status,
      exceededCategories: exceededCategories,
      safeCategories: safeCategories,
      categoryBudgetsCount: categoryBudgets.length,
    );
  }

  static List<MonthlyCategoryBreakdown> _categories(
    List<TransactionEntity> currentTx,
    List<TransactionEntity> previousTx,
    double totalExpense,
  ) {
    final currentGrouped = <String, (double, int)>{};
    for (final tx in currentTx.where((tx) => tx.type == 'expense')) {
      final existing = currentGrouped[tx.category] ?? (0.0, 0);
      currentGrouped[tx.category] = (existing.$1 + tx.amount, existing.$2 + 1);
    }

    final previousGrouped = <String, double>{};
    for (final tx in previousTx.where((tx) => tx.type == 'expense')) {
      final existing = previousGrouped[tx.category] ?? 0.0;
      previousGrouped[tx.category] = existing + tx.amount;
    }

    final categories = currentGrouped.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value.$1;
      final count = entry.value.$2;

      final prevAmount = previousGrouped[category] ?? 0.0;
      String trend = 'stable';
      if (amount > prevAmount) {
        trend = 'up';
      } else if (amount < prevAmount) {
        trend = 'down';
      }

      return MonthlyCategoryBreakdown(
        category: category,
        amount: amount,
        percentage: totalExpense > 0 ? (amount / totalExpense) * 100.0 : 0.0,
        transactionCount: count,
        trend: trend,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return categories;
  }

  static List<MonthlyTransactionItem> _timeline(List<TransactionEntity> transactions) {
    final sorted = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date)); // Descending order for timeline
    return sorted.map((tx) {
      return MonthlyTransactionItem(
        id: tx.uuid,
        date: tx.date,
        title: tx.title,
        type: tx.type,
        category: tx.category,
        amount: tx.amount,
      );
    }).toList();
  }

  static bool _sameDay(DateTime first, DateTime second) {
    return first.year == second.year && first.month == second.month && first.day == second.day;
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
}
