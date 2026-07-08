import 'dart:math';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/ai_insight_data.dart';

class ForecastService {
  const ForecastService._();

  static AIForecast calculate({
    required List<TransactionEntity> transactions,
  }) {
    final now = DateTime.now();
    final activeTx = transactions.where((tx) => !tx.isDeleted).toList();

    // Get current month transactions
    final currentMonthTx = activeTx
        .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
        .toList();

    double currentIncome = 0.0;
    double currentExpense = 0.0;

    for (final tx in currentMonthTx) {
      if (tx.type == 'income') currentIncome += tx.amount;
      if (tx.type == 'expense') currentExpense += tx.amount;
    }

    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day;
    final remainingDays = max(0, totalDaysInMonth - currentDay);

    // Calculate daily average expense
    final double dailyAvgExpense = currentDay > 0 ? currentExpense / currentDay : 0.0;
    final double remainingForecastExpenses = dailyAvgExpense * remainingDays;

    final double projectedTotalExpenses = currentExpense + remainingForecastExpenses;
    final double expectedSavings = max(0.0, currentIncome - projectedTotalExpenses);

    return AIForecast(
      remainingMonthExpenses: remainingForecastExpenses,
      expectedSavings: expectedSavings,
      budgetCompletionRate: currentIncome > 0 ? (projectedTotalExpenses / currentIncome) * 100 : 0.0,
      projectedCashFlow: currentIncome - projectedTotalExpenses,
    );
  }
}
