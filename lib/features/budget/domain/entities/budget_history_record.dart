class BudgetHistoryRecord {
  final String month;
  final int year;
  final double budgetAmount;
  final double spentAmount;
  final double remainingAmount;
  final double savings;
  final double utilizationPercentage;
  final String status; // Successful, Exceeded, etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetHistoryRecord({
    required this.month,
    required this.year,
    required this.budgetAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.savings,
    required this.utilizationPercentage,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
