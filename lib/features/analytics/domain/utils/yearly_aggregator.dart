import 'dart:math';

import '../../../budget/domain/entities/budget_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/yearly_report_data.dart';
import 'year_comparison_service.dart';
import 'yearly_analytics_engine.dart';

class YearlyAggregator {
  const YearlyAggregator._();

  static YearlyReport aggregate({
    required List<TransactionEntity> transactions,
    required List<BudgetEntity> budgets,
    required DateTime yearAnchor,
  }) {
    final yearStart = DateTime(yearAnchor.year, 1, 1);
    final yearEnd = DateTime(yearAnchor.year, 12, 31, 23, 59, 59);

    final prevYearStart = DateTime(yearAnchor.year - 1, 1, 1);
    final prevYearEnd = DateTime(yearAnchor.year - 1, 12, 31, 23, 59, 59);

    final activeTx = transactions.where((tx) => !tx.isDeleted).toList();

    final currentTx = activeTx.where((tx) => !tx.date.isBefore(yearStart) && !tx.date.isAfter(yearEnd)).toList();
    final previousTx = activeTx.where((tx) => !tx.date.isBefore(prevYearStart) && !tx.date.isAfter(prevYearEnd)).toList();

    final summary = _summary(currentTx);
    final previousSummary = _summary(previousTx);

    final monthlyBreakdown = _monthlyBreakdown(currentTx, yearAnchor.year);
    final statistics = _statistics(currentTx, monthlyBreakdown);

    final activeBudgets = budgets.where((b) {
      if (b.isDeleted) return false;
      return !b.startDate.isAfter(yearEnd) && !b.endDate.isBefore(yearStart);
    }).toList();

    final prevActiveBudgets = budgets.where((b) {
      if (b.isDeleted) return false;
      return !b.startDate.isAfter(prevYearEnd) && !b.endDate.isBefore(prevYearStart);
    }).toList();

    final budgetProgress = _budgetProgress(currentTx, activeBudgets);
    final prevBudgetProgress = _budgetProgress(previousTx, prevActiveBudgets);

    final categories = _categories(currentTx, previousTx, summary.expense);
    final timeline = _timeline(currentTx);

    final comparison = YearComparisonService.compare(
      current: summary,
      previous: previousSummary,
      currentBudgetSpent: budgetProgress.spent,
      previousBudgetSpent: prevBudgetProgress.spent,
      currentTransactionsCount: currentTx.length,
      previousTransactionsCount: previousTx.length,
    );

    final health = YearlyAnalyticsEngine.calculateHealth(
      summary: summary,
      budgetProgress: budgetProgress,
    );

    final insights = YearlyAnalyticsEngine.generateInsights(
      summary: summary,
      comparison: comparison,
      budgetProgress: budgetProgress,
      categories: categories,
    );

    return YearlyReport(
      yearStart: yearStart,
      yearEnd: yearEnd,
      summary: summary,
      statistics: statistics,
      budgetProgress: budgetProgress,
      categories: categories,
      monthlyBreakdown: monthlyBreakdown,
      timeline: timeline,
      comparison: comparison,
      health: health,
      insights: insights,
      exportHooks: YearlyReportExportHooks.enabled(),
    );
  }

  static YearlySummary _summary(List<TransactionEntity> transactions) {
    double income = 0;
    double expense = 0;
    for (final tx in transactions) {
      if (tx.type == 'income') income += tx.amount;
      if (tx.type == 'expense') expense += tx.amount;
    }
    return YearlySummary(
      income: income,
      expense: expense,
      savings: income - expense,
      cashFlow: income - expense,
    );
  }

  static List<YearlyMonthBreakdown> _monthlyBreakdown(
    List<TransactionEntity> transactions,
    int year,
  ) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return List.generate(12, (index) {
      final month = index + 1;
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 1).subtract(const Duration(seconds: 1));

      final monthTx = transactions.where((tx) => !tx.date.isBefore(start) && !tx.date.isAfter(end)).toList();
      final monthSummary = _summary(monthTx);

      return YearlyMonthBreakdown(
        month: month,
        monthName: monthNames[index],
        income: monthSummary.income,
        expense: monthSummary.expense,
        savings: monthSummary.savings,
        cashFlow: monthSummary.cashFlow,
        budgetStatus: 'Safe', // Simple mock status for monthly granularity
      );
    });
  }

  static YearlyStatistics _statistics(
    List<TransactionEntity> transactions,
    List<YearlyMonthBreakdown> months,
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

    final totalIncome = incomeTx.fold<double>(0, (sum, tx) => sum + tx.amount);
    final totalExpense = expenseTx.fold<double>(0, (sum, tx) => sum + tx.amount);

    String highestSpendingMonth = 'None';
    String highestSavingMonth = 'None';
    String lowestExpenseMonth = 'None';
    String bestFinancialMonth = 'None';
    String worstFinancialMonth = 'None';

    if (months.isNotEmpty) {
      final maxSpend = months.reduce((a, b) => a.expense >= b.expense ? a : b);
      highestSpendingMonth = maxSpend.expense > 0 ? maxSpend.monthName : 'None';

      final maxSave = months.reduce((a, b) => a.savings >= b.savings ? a : b);
      highestSavingMonth = maxSave.savings > 0 ? maxSave.monthName : 'None';

      final activeMonths = months.where((m) => m.expense > 0).toList();
      if (activeMonths.isNotEmpty) {
        final minSpend = activeMonths.reduce((a, b) => a.expense <= b.expense ? a : b);
        lowestExpenseMonth = minSpend.monthName;
      }

      final maxCashFlow = months.reduce((a, b) => a.cashFlow >= b.cashFlow ? a : b);
      bestFinancialMonth = maxCashFlow.cashFlow > 0 ? maxCashFlow.monthName : 'None';

      final minCashFlow = months.reduce((a, b) => a.cashFlow <= b.cashFlow ? a : b);
      worstFinancialMonth = minCashFlow.cashFlow < 0 ? minCashFlow.monthName : 'None';
    }

    return YearlyStatistics(
      totalTransactions: transactions.length,
      incomeTransactions: incomeTx.length,
      expenseTransactions: expenseTx.length,
      averageMonthlyExpense: totalExpense / 12,
      averageMonthlyIncome: totalIncome / 12,
      averageSavings: (totalIncome - totalExpense) / 12,
      averageTransaction: transactions.isEmpty ? 0.0 : totalAmount / transactions.length,
      netWorthGrowth: totalIncome - totalExpense,
      largestExpense: largestExpense,
      largestIncome: largestIncome,
      highestSpendingMonth: highestSpendingMonth,
      highestSavingMonth: highestSavingMonth,
      lowestExpenseMonth: lowestExpenseMonth,
      bestFinancialMonth: bestFinancialMonth,
      worstFinancialMonth: worstFinancialMonth,
    );
  }

  static YearlyBudgetProgress _budgetProgress(
    List<TransactionEntity> transactions,
    List<BudgetEntity> activeBudgets,
  ) {
    if (activeBudgets.isEmpty) {
      return YearlyBudgetProgress.zero();
    }

    final totalBudgets = activeBudgets.where((b) => b.categoryId == null || b.budgetType == 'total').toList();
    final categoryBudgets = activeBudgets.where((b) => b.categoryId != null && b.budgetType == 'category').toList();

    double budgetLimit = 0.0;
    double spent = 0.0;

    if (totalBudgets.isNotEmpty) {
      budgetLimit = totalBudgets.fold<double>(0, (sum, b) => sum + b.amount);
      spent = transactions
          .where((tx) => tx.type == 'expense')
          .fold<double>(0, (sum, tx) => sum + tx.amount);
    } else {
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

    final complianceScore = budgetLimit > 0
        ? max(0.0, 100.0 - (exceededCategories.length / max(1, categoryBudgets.length) * 100.0))
        : 100.0;

    return YearlyBudgetProgress(
      budgetLimit: budgetLimit,
      spent: spent,
      remaining: max(0.0, budgetLimit - spent),
      utilization: utilization,
      status: status,
      exceededCategories: exceededCategories,
      safeCategories: safeCategories,
      categoryBudgetsCount: categoryBudgets.length,
      complianceScore: complianceScore,
    );
  }

  static List<YearlyCategoryBreakdown> _categories(
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

      return YearlyCategoryBreakdown(
        category: category,
        amount: amount,
        percentage: totalExpense > 0 ? (amount / totalExpense) * 100.0 : 0.0,
        transactionCount: count,
        trend: trend,
        monthlyAverage: amount / 12,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return categories;
  }

  static List<YearlyTransactionItem> _timeline(List<TransactionEntity> transactions) {
    final sorted = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.map((tx) {
      return YearlyTransactionItem(
        id: tx.uuid,
        date: tx.date,
        title: tx.title,
        type: tx.type,
        category: tx.category,
        amount: tx.amount,
      );
    }).toList();
  }
}
