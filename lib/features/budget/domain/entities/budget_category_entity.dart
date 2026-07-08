class BudgetCategoryEntity {
  final String uuid;
  final String budgetId;
  final String categoryId;
  final double allocatedAmount;
  final double spentAmount;
  final double remainingAmount;
  final double progress;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetCategoryEntity({
    required this.uuid,
    required this.budgetId,
    required this.categoryId,
    required this.allocatedAmount,
    this.spentAmount = 0.0,
    this.remainingAmount = 0.0,
    this.progress = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });
}
