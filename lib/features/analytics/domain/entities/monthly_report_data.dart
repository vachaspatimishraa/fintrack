class MonthlySummary {
  final double income;
  final double expense;
  final double savings;
  final double cashFlow;

  const MonthlySummary({
    required this.income,
    required this.expense,
    required this.savings,
    required this.cashFlow,
  });

  factory MonthlySummary.zero() => const MonthlySummary(
        income: 0.0,
        expense: 0.0,
        savings: 0.0,
        cashFlow: 0.0,
      );
}

class MonthlyDayBreakdown {
  final DateTime date;
  final String weekday;
  final double income;
  final double expense;
  final double savings;
  final int transactionCount;

  const MonthlyDayBreakdown({
    required this.date,
    required this.weekday,
    required this.income,
    required this.expense,
    required this.savings,
    required this.transactionCount,
  });
}

class MonthlyCategoryBreakdown {
  final String category;
  final double amount;
  final double percentage;
  final int transactionCount;
  final String trend; // "up", "down", "stable" or percentage

  const MonthlyCategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    required this.trend,
  });
}

class MonthlyStatistics {
  final int totalTransactions;
  final int incomeTransactions;
  final int expenseTransactions;
  final double averageDailyExpense;
  final double averageDailyIncome;
  final double averageTransaction;
  final double largestExpense;
  final double largestIncome;
  final double netSavings;
  final MonthlyDayBreakdown? mostActiveDay;
  final MonthlyDayBreakdown? leastActiveDay;

  const MonthlyStatistics({
    required this.totalTransactions,
    required this.incomeTransactions,
    required this.expenseTransactions,
    required this.averageDailyExpense,
    required this.averageDailyIncome,
    required this.averageTransaction,
    required this.largestExpense,
    required this.largestIncome,
    required this.netSavings,
    required this.mostActiveDay,
    required this.leastActiveDay,
  });

  factory MonthlyStatistics.zero() => const MonthlyStatistics(
        totalTransactions: 0,
        incomeTransactions: 0,
        expenseTransactions: 0,
        averageDailyExpense: 0,
        averageDailyIncome: 0,
        averageTransaction: 0,
        largestExpense: 0,
        largestIncome: 0,
        netSavings: 0,
        mostActiveDay: null,
        leastActiveDay: null,
      );
}

class MonthlyBudgetProgress {
  final double budgetLimit;
  final double spent;
  final double remaining;
  final double utilization; // spent / budgetLimit, 0 to 1
  final String status; // Safe, Warning, Critical, Exceeded, Completed
  final List<String> exceededCategories;
  final List<String> safeCategories;
  final int categoryBudgetsCount;

  const MonthlyBudgetProgress({
    required this.budgetLimit,
    required this.spent,
    required this.remaining,
    required this.utilization,
    required this.status,
    required this.exceededCategories,
    required this.safeCategories,
    required this.categoryBudgetsCount,
  });

  factory MonthlyBudgetProgress.zero() => const MonthlyBudgetProgress(
        budgetLimit: 0.0,
        spent: 0.0,
        remaining: 0.0,
        utilization: 0.0,
        status: 'Safe',
        exceededCategories: [],
        safeCategories: [],
        categoryBudgetsCount: 0,
      );
}

class MonthlyComparison {
  final double incomeChange;
  final double expenseChange;
  final double savingsChange;
  final double cashFlowChange;
  final double incomeGrowthPercentage;
  final double expenseGrowthPercentage;
  final double savingsGrowthPercentage;
  final double cashFlowGrowthPercentage;
  final double budgetDifference;
  final double transactionDifference;

  const MonthlyComparison({
    required this.incomeChange,
    required this.expenseChange,
    required this.savingsChange,
    required this.cashFlowChange,
    required this.incomeGrowthPercentage,
    required this.expenseGrowthPercentage,
    required this.savingsGrowthPercentage,
    required this.cashFlowGrowthPercentage,
    required this.budgetDifference,
    required this.transactionDifference,
  });

  factory MonthlyComparison.zero() => const MonthlyComparison(
        incomeChange: 0,
        expenseChange: 0,
        savingsChange: 0,
        cashFlowChange: 0,
        incomeGrowthPercentage: 0,
        expenseGrowthPercentage: 0,
        savingsGrowthPercentage: 0,
        cashFlowGrowthPercentage: 0,
        budgetDifference: 0,
        transactionDifference: 0,
      );
}

class MonthlyScore {
  final double score;
  final String grade;
  final String status;
  final List<String> factors;

  const MonthlyScore({
    required this.score,
    required this.grade,
    required this.status,
    required this.factors,
  });

  factory MonthlyScore.zero() => const MonthlyScore(
        score: 0.0,
        grade: 'F',
        status: 'Needs Attention',
        factors: [],
      );
}

class MonthlyTransactionItem {
  final String id;
  final DateTime date;
  final String title;
  final String type;
  final String category;
  final double amount;

  const MonthlyTransactionItem({
    required this.id,
    required this.date,
    required this.title,
    required this.type,
    required this.category,
    required this.amount,
  });
}

class MonthlyReportExportHooks {
  final bool pdf;
  final bool excel;
  final bool csv;
  final bool share;
  final bool print;

  const MonthlyReportExportHooks({
    required this.pdf,
    required this.excel,
    required this.csv,
    required this.share,
    required this.print,
  });

  factory MonthlyReportExportHooks.enabled() => const MonthlyReportExportHooks(
        pdf: true,
        excel: true,
        csv: true,
        share: true,
        print: true,
      );
}

class MonthlyReport {
  final DateTime monthStart;
  final DateTime monthEnd;
  final MonthlySummary summary;
  final MonthlyStatistics statistics;
  final MonthlyBudgetProgress budgetProgress;
  final List<MonthlyCategoryBreakdown> categories;
  final List<MonthlyDayBreakdown> dailyBreakdown;
  final List<MonthlyTransactionItem> timeline;
  final MonthlyComparison comparison;
  final MonthlyScore score;
  final List<String> recommendations;
  final MonthlyReportExportHooks exportHooks;

  const MonthlyReport({
    required this.monthStart,
    required this.monthEnd,
    required this.summary,
    required this.statistics,
    required this.budgetProgress,
    required this.categories,
    required this.dailyBreakdown,
    required this.timeline,
    required this.comparison,
    required this.score,
    required this.recommendations,
    required this.exportHooks,
  });

  bool get isEmpty => statistics.totalTransactions == 0;
}
