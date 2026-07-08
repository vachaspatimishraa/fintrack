class CategoryBudgetDistribution {
  final String categoryId;
  final String categoryName;
  final double allocatedAmount;
  final double spentAmount;
  final double percentageOfTotalBudget;
  final double progress;

  CategoryBudgetDistribution({
    required this.categoryId,
    required this.categoryName,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.percentageOfTotalBudget,
    required this.progress,
  });
}
