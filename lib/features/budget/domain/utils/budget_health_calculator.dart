import '../entities/budget_entity.dart';

class BudgetHealthCalculator {
  static Future<double> calculateScore(List<BudgetEntity> budgets) async {
    if (budgets.isEmpty) return 100.0;

    double totalScore = 0.0;
    int budgetCount = budgets.length;

    for (final budget in budgets) {
      double budgetScore = 100.0;
      
      // Deduction for overspending
      if (budget.progress > 100) {
        final overspendPercent = budget.progress - 100;
        budgetScore -= overspendPercent * 2; // Aggressive deduction for overspending
      } else if (budget.progress > 80) {
        budgetScore -= (budget.progress - 80) * 0.5; // Minor deduction for near limit
      }

      if (budgetScore < 0) budgetScore = 0;
      totalScore += budgetScore;
    }

    return totalScore / budgetCount;
  }

  static String getStatus(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Average';
    if (score >= 20) return 'Poor';
    return 'Critical';
  }
}
