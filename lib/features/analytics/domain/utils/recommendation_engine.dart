import '../entities/financial_health_data.dart';

class RecommendationEngine {
  const RecommendationEngine._();

  static void analyze({
    required HealthBreakdown breakdown,
    required List<String> strengths,
    required List<String> weaknesses,
    required List<String> recommendations,
  }) {
    // Strengths Detection
    if (breakdown.savingsScore >= 75) {
      strengths.add('Healthy Savings Rate (excellent reserves generated)');
    }
    if (breakdown.budgetScore >= 75) {
      strengths.add('Excellent Budget Discipline (minimal budget violations)');
    }
    if (breakdown.cashFlowScore >= 75) {
      strengths.add('Positive Cash Flow (regular financial surplus)');
    }
    if (breakdown.expenseScore >= 75) {
      strengths.add('Strong Expense Control (discretionary spending managed)');
    }
    if (breakdown.incomeScore >= 75) {
      strengths.add('Stable Income Source (reliable monthly inflows)');
    }
    if (breakdown.consistencyScore >= 75) {
      strengths.add('Financial Routine (highly consistent transactional habits)');
    }

    // Weaknesses Detection
    if (breakdown.savingsScore < 60) {
      weaknesses.add('Low Savings (reserve levels below safe margins)');
    }
    if (breakdown.budgetScore < 60) {
      weaknesses.add('Frequent Overspending (multiple budgets breached)');
    }
    if (breakdown.cashFlowScore < 60) {
      weaknesses.add('Deficit Cash Flow (monthly spending exceeding earnings)');
    }
    if (breakdown.expenseScore < 60) {
      weaknesses.add('High Expense Ratio (disproportionate consumption rate)');
    }
    if (breakdown.incomeScore < 60) {
      weaknesses.add('Volatile Income (unstable monthly salary/payment arrivals)');
    }
    if (breakdown.consistencyScore < 60) {
      weaknesses.add('Inconsistent Logging (untracked periods of activity)');
    }

    // Recommendations Generation
    if (breakdown.savingsScore < 60) {
      recommendations.add('Aim to increase savings by 10% by automating a portion of income deposits.');
    }
    if (breakdown.budgetScore < 60) {
      recommendations.add('Reduce non-essential shopping and set up alerts for categories approaching thresholds.');
    }
    if (breakdown.cashFlowScore < 60) {
      recommendations.add('Build a solid emergency fund worth 3 months of expenses to secure cash flow.');
    }
    if (breakdown.expenseScore < 60) {
      recommendations.add('Perform a weekly audit of luxury subscriptions or dine-out activities.');
    }
    if (breakdown.consistencyScore < 60) {
      recommendations.add('Set a daily reminder to log receipt details and maintain tracking routines.');
    }

    // Default positive reinforcements
    if (recommendations.isEmpty) {
      recommendations.add('Maintain current budget discipline. Excellent wellness score!');
    }
  }
}
