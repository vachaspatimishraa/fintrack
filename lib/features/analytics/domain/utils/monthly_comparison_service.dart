import '../entities/monthly_report_data.dart';

class MonthlyComparisonService {
  const MonthlyComparisonService._();

  static double growth(double current, double previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100.0;
  }

  static MonthlyComparison compare({
    required MonthlySummary current,
    required MonthlySummary previous,
    required double currentBudgetSpent,
    required double previousBudgetSpent,
    required int currentTransactionsCount,
    required int previousTransactionsCount,
  }) {
    return MonthlyComparison(
      incomeChange: current.income - previous.income,
      expenseChange: current.expense - previous.expense,
      savingsChange: current.savings - previous.savings,
      cashFlowChange: current.cashFlow - previous.cashFlow,
      incomeGrowthPercentage: growth(current.income, previous.income),
      expenseGrowthPercentage: growth(current.expense, previous.expense),
      savingsGrowthPercentage: growth(current.savings, previous.savings),
      cashFlowGrowthPercentage: growth(current.cashFlow, previous.cashFlow),
      budgetDifference: currentBudgetSpent - previousBudgetSpent,
      transactionDifference: (currentTransactionsCount - previousTransactionsCount).toDouble(),
    );
  }
}
