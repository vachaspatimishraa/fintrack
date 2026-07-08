class WeeklySummary {
  final double income;
  final double expense;
  final double savings;
  final double cashFlow;

  const WeeklySummary({
    required this.income,
    required this.expense,
    required this.savings,
    required this.cashFlow,
  });
}

class WeeklyDayBreakdown {
  final DateTime date;
  final String weekday;
  final double income;
  final double expense;
  final double savings;
  final int transactionCount;

  const WeeklyDayBreakdown({
    required this.date,
    required this.weekday,
    required this.income,
    required this.expense,
    required this.savings,
    required this.transactionCount,
  });
}

class WeeklyCategoryBreakdown {
  final String category;
  final double amount;
  final double percentage;
  final int transactionCount;

  const WeeklyCategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

class WeeklyStatistics {
  final int totalTransactions;
  final int incomeTransactions;
  final int expenseTransactions;
  final double averageDailyExpense;
  final double averageDailyIncome;
  final double averageTransaction;
  final double largestExpense;
  final double largestIncome;
  final WeeklyDayBreakdown? mostActiveDay;
  final WeeklyDayBreakdown? leastActiveDay;

  const WeeklyStatistics({
    required this.totalTransactions,
    required this.incomeTransactions,
    required this.expenseTransactions,
    required this.averageDailyExpense,
    required this.averageDailyIncome,
    required this.averageTransaction,
    required this.largestExpense,
    required this.largestIncome,
    required this.mostActiveDay,
    required this.leastActiveDay,
  });
}

class WeeklyComparison {
  final double incomeChange;
  final double expenseChange;
  final double savingsChange;
  final double cashFlowChange;
  final double incomeGrowthPercentage;
  final double expenseGrowthPercentage;
  final double savingsGrowthPercentage;
  final double cashFlowGrowthPercentage;

  const WeeklyComparison({
    required this.incomeChange,
    required this.expenseChange,
    required this.savingsChange,
    required this.cashFlowChange,
    required this.incomeGrowthPercentage,
    required this.expenseGrowthPercentage,
    required this.savingsGrowthPercentage,
    required this.cashFlowGrowthPercentage,
  });
}

class WeeklyScore {
  final double score;
  final String grade;
  final String status;
  final List<String> factors;

  const WeeklyScore({
    required this.score,
    required this.grade,
    required this.status,
    required this.factors,
  });
}

class WeeklyTransactionItem {
  final String id;
  final DateTime date;
  final String title;
  final String type;
  final String category;
  final double amount;

  const WeeklyTransactionItem({
    required this.id,
    required this.date,
    required this.title,
    required this.type,
    required this.category,
    required this.amount,
  });
}

class WeeklyReportExportHooks {
  final bool pdf;
  final bool excel;
  final bool csv;
  final bool share;
  final bool print;

  const WeeklyReportExportHooks({
    required this.pdf,
    required this.excel,
    required this.csv,
    required this.share,
    required this.print,
  });

  factory WeeklyReportExportHooks.enabled() => const WeeklyReportExportHooks(
        pdf: true,
        excel: true,
        csv: true,
        share: true,
        print: true,
      );
}

class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final WeeklySummary summary;
  final WeeklyStatistics statistics;
  final List<WeeklyCategoryBreakdown> categories;
  final List<WeeklyDayBreakdown> dailyBreakdown;
  final List<WeeklyTransactionItem> timeline;
  final WeeklyComparison comparison;
  final WeeklyScore score;
  final List<String> recommendations;
  final WeeklyReportExportHooks exportHooks;

  const WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.summary,
    required this.statistics,
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
