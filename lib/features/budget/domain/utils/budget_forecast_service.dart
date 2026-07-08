import '../entities/budget_entity.dart';

class BudgetForecastService {
  static double calculateLinearForecast(BudgetEntity budget) {
    if (budget.amount <= 0) return 0.0;
    
    final now = DateTime.now();
    if (now.isBefore(budget.startDate)) return 0.0;
    if (now.isAfter(budget.endDate)) return budget.spentAmount;

    final daysPassed = now.difference(budget.startDate).inDays;
    if (daysPassed <= 0) return budget.spentAmount;

    final totalDays = budget.endDate.difference(budget.startDate).inDays;
    if (totalDays <= 0) return budget.spentAmount;

    final avgDailySpending = budget.spentAmount / daysPassed;
    return avgDailySpending * totalDays;
  }
}
