import '../entities/weekly_report_data.dart';

class WeeklyComparisonService {
  const WeeklyComparisonService._();

  static double growth(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  static WeeklyComparison compare({
    required WeeklySummary current,
    required WeeklySummary previous,
  }) {
    return WeeklyComparison(
      incomeChange: current.income - previous.income,
      expenseChange: current.expense - previous.expense,
      savingsChange: current.savings - previous.savings,
      cashFlowChange: current.cashFlow - previous.cashFlow,
      incomeGrowthPercentage: growth(current.income, previous.income),
      expenseGrowthPercentage: growth(current.expense, previous.expense),
      savingsGrowthPercentage: growth(current.savings, previous.savings),
      cashFlowGrowthPercentage: growth(current.cashFlow, previous.cashFlow),
    );
  }
}
