class YearlySummary {
  final double income;
  final double expense;
  final double savings;
  final double cashFlow;

  const YearlySummary({
    required this.income,
    required this.expense,
    required this.savings,
    required this.cashFlow,
  });

  factory YearlySummary.zero() => const YearlySummary(
        income: 0.0,
        expense: 0.0,
        savings: 0.0,
        cashFlow: 0.0,
      );
}

class YearlyMonthBreakdown {
  final int month;
  final String monthName;
  final double income;
  final double expense;
  final double savings;
  final double cashFlow;
  final String budgetStatus; // Safe, Warning, Critical, Exceeded

  const YearlyMonthBreakdown({
    required this.month,
    required this.monthName,
    required this.income,
    required this.expense,
    required this.savings,
    required this.cashFlow,
    required this.budgetStatus,
  });
}

class YearlyCategoryBreakdown {
  final String category;
  final double amount;
  final double percentage;
  final int transactionCount;
  final String trend; // "up", "down", "stable"
  final double monthlyAverage;

  const YearlyCategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    required this.trend,
    required this.monthlyAverage,
  });
}

class YearlyStatistics {
  final int totalTransactions;
  final int incomeTransactions;
  final int expenseTransactions;
  final double averageMonthlyExpense;
  final double averageMonthlyIncome;
  final double averageSavings;
  final double averageTransaction;
  final double netWorthGrowth; // final balance change or MoM balance change
  final double largestExpense;
  final double largestIncome;
  final String highestSpendingMonth;
  final String highestSavingMonth;
  final String lowestExpenseMonth;
  final String bestFinancialMonth;
  final String worstFinancialMonth;

  const YearlyStatistics({
    required this.totalTransactions,
    required this.incomeTransactions,
    required this.expenseTransactions,
    required this.averageMonthlyExpense,
    required this.averageMonthlyIncome,
    required this.averageSavings,
    required this.averageTransaction,
    required this.netWorthGrowth,
    required this.largestExpense,
    required this.largestIncome,
    required this.highestSpendingMonth,
    required this.highestSavingMonth,
    required this.lowestExpenseMonth,
    required this.bestFinancialMonth,
    required this.worstFinancialMonth,
  });

  factory YearlyStatistics.zero() => const YearlyStatistics(
        totalTransactions: 0,
        incomeTransactions: 0,
        expenseTransactions: 0,
        averageMonthlyExpense: 0,
        averageMonthlyIncome: 0,
        averageSavings: 0,
        averageTransaction: 0,
        netWorthGrowth: 0,
        largestExpense: 0,
        largestIncome: 0,
        highestSpendingMonth: 'None',
        highestSavingMonth: 'None',
        lowestExpenseMonth: 'None',
        bestFinancialMonth: 'None',
        worstFinancialMonth: 'None',
      );
}

class YearlyBudgetProgress {
  final double budgetLimit;
  final double spent;
  final double remaining;
  final double utilization; // spent / budgetLimit, 0 to 1
  final String status; // Safe, Warning, Critical, Exceeded, Completed
  final List<String> exceededCategories;
  final List<String> safeCategories;
  final int categoryBudgetsCount;
  final double complianceScore; // 0 to 100

  const YearlyBudgetProgress({
    required this.budgetLimit,
    required this.spent,
    required this.remaining,
    required this.utilization,
    required this.status,
    required this.exceededCategories,
    required this.safeCategories,
    required this.categoryBudgetsCount,
    required this.complianceScore,
  });

  factory YearlyBudgetProgress.zero() => const YearlyBudgetProgress(
        budgetLimit: 0.0,
        spent: 0.0,
        remaining: 0.0,
        utilization: 0.0,
        status: 'Safe',
        exceededCategories: [],
        safeCategories: [],
        categoryBudgetsCount: 0,
        complianceScore: 100.0,
      );
}

class YearlyComparison {
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

  const YearlyComparison({
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

  factory YearlyComparison.zero() => const YearlyComparison(
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

class YearlyHealth {
  final double score;
  final String grade;
  final String status;
  final List<String> factors;

  const YearlyHealth({
    required this.score,
    required this.grade,
    required this.status,
    required this.factors,
  });

  factory YearlyHealth.zero() => const YearlyHealth(
        score: 0.0,
        grade: 'F',
        status: 'Needs Attention',
        factors: [],
      );
}

class YearlyTransactionItem {
  final String id;
  final DateTime date;
  final String title;
  final String type;
  final String category;
  final double amount;

  const YearlyTransactionItem({
    required this.id,
    required this.date,
    required this.title,
    required this.type,
    required this.category,
    required this.amount,
  });
}

class YearlyReportExportHooks {
  final bool pdf;
  final bool excel;
  final bool csv;
  final bool share;
  final bool print;

  const YearlyReportExportHooks({
    required this.pdf,
    required this.excel,
    required this.csv,
    required this.share,
    required this.print,
  });

  factory YearlyReportExportHooks.enabled() => const YearlyReportExportHooks(
        pdf: true,
        excel: true,
        csv: true,
        share: true,
        print: true,
      );
}

class YearlyReport {
  final DateTime yearStart;
  final DateTime yearEnd;
  final YearlySummary summary;
  final YearlyStatistics statistics;
  final YearlyBudgetProgress budgetProgress;
  final List<YearlyCategoryBreakdown> categories;
  final List<YearlyMonthBreakdown> monthlyBreakdown;
  final List<YearlyTransactionItem> timeline;
  final YearlyComparison comparison;
  final YearlyHealth health;
  final List<String> insights;
  final YearlyReportExportHooks exportHooks;

  const YearlyReport({
    required this.yearStart,
    required this.yearEnd,
    required this.summary,
    required this.statistics,
    required this.budgetProgress,
    required this.categories,
    required this.monthlyBreakdown,
    required this.timeline,
    required this.comparison,
    required this.health,
    required this.insights,
    required this.exportHooks,
  });

  bool get isEmpty => statistics.totalTransactions == 0;
}
