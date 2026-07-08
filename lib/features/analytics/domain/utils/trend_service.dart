import '../../../budget/domain/entities/budget_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/financial_health_data.dart';
import 'health_score_calculator.dart';

class TrendService {
  const TrendService._();

  static List<HistoricalHealthScore> generate({
    required List<TransactionEntity> transactions,
    required List<BudgetEntity> budgets,
  }) {
    final now = DateTime.now();
    final historicalPoints = <HistoricalHealthScore>[];

    // Generate checkpoints for the last 6 months
    for (int i = 5; i >= 0; i--) {
      final dateCheckpoint = DateTime(now.year, now.month - i, 1);
      final monthEndCheckpoint = DateTime(now.year, now.month - i + 1, 1).subtract(const Duration(seconds: 1));

      // Filter transactions up to this checkpoint month
      final txInMonth = transactions
          .where((tx) => !tx.isDeleted && tx.date.year == dateCheckpoint.year && tx.date.month == dateCheckpoint.month)
          .toList();

      final budgetsInMonth = budgets
          .where((b) => !b.isDeleted && !b.startDate.isAfter(monthEndCheckpoint) && !b.endDate.isBefore(dateCheckpoint))
          .toList();

      double income = 0.0;
      double expense = 0.0;
      for (final tx in txInMonth) {
        if (tx.type == 'income') income += tx.amount;
        if (tx.type == 'expense') expense += tx.amount;
      }

      final savings = HealthScoreCalculator.calculateSavingsScore(income, expense);
      final budget = HealthScoreCalculator.calculateBudgetScore(txInMonth, budgetsInMonth);
      final cashFlow = HealthScoreCalculator.calculateCashFlowScore(income, expense);
      final expenseCtrl = HealthScoreCalculator.calculateExpenseScore(income, expense);

      // Stability and consistency check for the checkpoint month
      final stability = HealthScoreCalculator.calculateIncomeStability(txInMonth);
      final consistency = HealthScoreCalculator.calculateConsistencyScore(txInMonth);

      final overall = HealthScoreCalculator.calculateOverallScore(
        savings: savings,
        budget: budget,
        cashFlow: cashFlow,
        expense: expenseCtrl,
        income: stability,
        consistency: consistency,
      );

      historicalPoints.add(
        HistoricalHealthScore(
          date: dateCheckpoint,
          overallScore: overall,
          savingsScore: savings,
          budgetScore: budget,
          cashFlowScore: cashFlow,
          expenseScore: expenseCtrl,
          incomeScore: stability,
          consistencyScore: consistency,
        ),
      );
    }

    return historicalPoints;
  }
}
