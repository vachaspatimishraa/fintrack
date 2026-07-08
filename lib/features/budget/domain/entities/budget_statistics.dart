class BudgetStatistics {
  final double totalBudget;
  final double totalSpent;
  final double remaining;
  final double overallProgress;
  final int activeBudgets;
  final int completedBudgets;
  final int exceededBudgets;
  final double averageBudget;
  final double averageSpending;

  BudgetStatistics({
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.overallProgress,
    required this.activeBudgets,
    required this.completedBudgets,
    required this.exceededBudgets,
    required this.averageBudget,
    required this.averageSpending,
  });
}
