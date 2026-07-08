import '../entities/budget_entity.dart';
import '../entities/category_budget_distribution.dart';

class CategoryBudgetCalculator {
  static List<CategoryBudgetDistribution> calculateDistribution(List<BudgetEntity> categoryBudgets) {
    final totalAllocated = categoryBudgets.fold(0.0, (sum, b) => sum + b.amount);
    if (totalAllocated == 0) return [];

    return categoryBudgets.map((b) {
      return CategoryBudgetDistribution(
        categoryId: b.categoryId ?? 'unknown',
        categoryName: b.title,
        allocatedAmount: b.amount,
        spentAmount: b.spentAmount,
        percentageOfTotalBudget: (b.amount / totalAllocated) * 100,
        progress: b.progress,
      );
    }).toList();
  }

  static List<BudgetEntity> rankBySpending(List<BudgetEntity> budgets) {
    final list = List<BudgetEntity>.from(budgets);
    list.sort((a, b) => b.spentAmount.compareTo(a.spentAmount));
    return list;
  }

  static List<BudgetEntity> rankByRemaining(List<BudgetEntity> budgets) {
    final list = List<BudgetEntity>.from(budgets);
    list.sort((a, b) => b.remainingAmount.compareTo(a.remainingAmount));
    return list;
  }

  static List<BudgetEntity> getExceededBudgets(List<BudgetEntity> budgets) {
    return budgets.where((b) => b.progress >= 100).toList();
  }
}
