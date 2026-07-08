import '../../../budget/domain/entities/budget_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/financial_health_data.dart';
import 'health_score_calculator.dart';
import 'recommendation_engine.dart';
import 'trend_service.dart';

class FinancialHealthEngine {
  const FinancialHealthEngine._();

  static FinancialHealthReport evaluate({
    required List<TransactionEntity> transactions,
    required List<BudgetEntity> budgets,
  }) {
    final activeTx = transactions.where((tx) => !tx.isDeleted).toList();
    if (activeTx.isEmpty) {
      return FinancialHealthReport.empty();
    }

    // Calculate current monthly figures
    final now = DateTime.now();
    final currentMonthTx = activeTx.where((tx) => tx.date.year == now.year && tx.date.month == now.month).toList();

    double income = 0.0;
    double expense = 0.0;

    for (final tx in currentMonthTx) {
      if (tx.type == 'income') income += tx.amount;
      if (tx.type == 'expense') expense += tx.amount;
    }

    // Calculate sub-scores
    final savings = HealthScoreCalculator.calculateSavingsScore(income, expense);
    final budget = HealthScoreCalculator.calculateBudgetScore(currentMonthTx, budgets);
    final cashFlow = HealthScoreCalculator.calculateCashFlowScore(income, expense);
    final expenseCtrl = HealthScoreCalculator.calculateExpenseScore(income, expense);
    final incomeStability = HealthScoreCalculator.calculateIncomeStability(activeTx);
    final consistency = HealthScoreCalculator.calculateConsistencyScore(activeTx);

    final overall = HealthScoreCalculator.calculateOverallScore(
      savings: savings,
      budget: budget,
      cashFlow: cashFlow,
      expense: expenseCtrl,
      income: incomeStability,
      consistency: consistency,
    );

    final breakdown = HealthBreakdown(
      savingsScore: savings,
      budgetScore: budget,
      cashFlowScore: cashFlow,
      expenseScore: expenseCtrl,
      incomeScore: incomeStability,
      consistencyScore: consistency,
    );

    final strengths = <String>[];
    final weaknesses = <String>[];
    final recommendations = <String>[];

    RecommendationEngine.analyze(
      breakdown: breakdown,
      strengths: strengths,
      weaknesses: weaknesses,
      recommendations: recommendations,
    );

    final historical = TrendService.generate(transactions: activeTx, budgets: budgets);

    return FinancialHealthReport(
      overallScore: overall,
      rating: _getRating(overall),
      ratingDescription: _getRatingDescription(overall),
      improvementAdvice: _getImprovementAdvice(overall),
      breakdown: breakdown,
      strengths: strengths,
      weaknesses: weaknesses,
      recommendations: recommendations,
      historicalScores: historical,
      isEmpty: false,
    );
  }

  static String _getRating(double score) {
    if (score >= 81) return 'Excellent';
    if (score >= 61) return 'Good';
    if (score >= 41) return 'Average';
    if (score >= 21) return 'Poor';
    return 'Critical';
  }

  static String _getRatingDescription(double score) {
    if (score >= 81) return 'Your financial habits are exemplary, ensuring growth and security.';
    if (score >= 61) return 'You maintain a strong balance of savings and budget discipline.';
    if (score >= 41) return 'Your finances are stable, but minor adjustments can enhance growth.';
    if (score >= 21) return 'Deficits and overspending present risks to your long-term wellness.';
    return 'Immediate corrective actions are needed to stabilize your reserves.';
  }

  static String _getImprovementAdvice(double score) {
    if (score >= 81) return 'Keep up the consistent saving and allocate funds to investments.';
    if (score >= 61) return 'Focus on minor expense categories to push score to Excellent.';
    if (score >= 41) return 'Audit recurring luxury transactions and increase monthly savings.';
    if (score >= 21) return 'Adopt a strict zero-based budget and build a basic emergency fund.';
    return 'Stop discretionary spending completely until cash flow balances.';
  }
}
