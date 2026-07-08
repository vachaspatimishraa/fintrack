class BudgetAnalytics {
  final double currentMonthBudget;
  final double currentMonthSpent;
  final double remainingBudget;
  final double utilizationPercentage;
  final double averageDailySpending;
  final double remainingDailyLimit;
  final double monthlySavings;
  final double overspentAmount;
  final double forecastedSpending;
  final double budgetEfficiencyScore; // 0-100
  final String healthStatus; // Excellent, Good, Average, Poor, Critical
  final double successRate;

  BudgetAnalytics({
    required this.currentMonthBudget,
    required this.currentMonthSpent,
    required this.remainingBudget,
    required this.utilizationPercentage,
    required this.averageDailySpending,
    required this.remainingDailyLimit,
    required this.monthlySavings,
    required this.overspentAmount,
    required this.forecastedSpending,
    required this.budgetEfficiencyScore,
    required this.healthStatus,
    required this.successRate,
  });
}
