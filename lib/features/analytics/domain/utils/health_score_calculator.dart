import 'dart:math';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../budget/domain/entities/budget_entity.dart';

class HealthScoreCalculator {
  const HealthScoreCalculator._();

  static double calculateSavingsScore(double income, double expense) {
    if (income <= 0) {
      return expense > 0 ? 10.0 : 50.0;
    }
    final ratio = (income - expense) / income;
    if (ratio >= 0.30) return 100.0;
    if (ratio >= 0.20) return 80.0;
    if (ratio >= 0.10) return 60.0;
    if (ratio >= 0.0) return 40.0;
    return max(0.0, 40.0 + (ratio * 100.0)); // Negative savings
  }

  static double calculateBudgetScore(List<TransactionEntity> transactions, List<BudgetEntity> budgets) {
    if (budgets.isEmpty) return 75.0; // Default baseline compliance

    int totalBudgets = budgets.length;
    int exceeded = 0;

    for (final b in budgets) {
      if (b.isDeleted) {
        totalBudgets--;
        continue;
      }
      // Calculate spent for this budget category
      final spent = transactions
          .where((tx) => !tx.isDeleted && tx.type == 'expense' && (tx.categoryId == b.categoryId || tx.category == b.title))
          .fold<double>(0.0, (sum, tx) => sum + tx.amount);

      if (spent > b.amount) {
        exceeded++;
      }
    }

    if (totalBudgets <= 0) return 75.0;

    final successRate = (totalBudgets - exceeded) / totalBudgets;
    return successRate * 100.0;
  }

  static double calculateExpenseScore(double income, double expense) {
    if (income <= 0) {
      return expense > 0 ? 10.0 : 100.0;
    }
    final ratio = expense / income;
    if (ratio <= 0.50) return 100.0;
    if (ratio <= 0.70) return 85.0;
    if (ratio <= 0.90) return 65.0;
    if (ratio <= 1.0) return 50.0;
    return max(0.0, 50.0 - ((ratio - 1.0) * 100.0));
  }

  static double calculateCashFlowScore(double income, double expense) {
    final cashFlow = income - expense;
    if (cashFlow > 0) return 100.0;
    if (cashFlow == 0) return 50.0;
    // Penalize based on deficit relative to income
    final denominator = income <= 0 ? 1000.0 : income;
    final penalty = (cashFlow.abs() / denominator) * 100.0;
    return max(0.0, 50.0 - penalty);
  }

  static double calculateIncomeStability(List<TransactionEntity> transactions) {
    final incomeTx = transactions.where((tx) => !tx.isDeleted && tx.type == 'income').toList();
    if (incomeTx.isEmpty) return 10.0;

    // Check months variance
    final monthlyAmounts = <int, double>{};
    for (final tx in incomeTx) {
      final month = tx.date.month;
      monthlyAmounts[month] = (monthlyAmounts[month] ?? 0) + tx.amount;
    }

    if (monthlyAmounts.length <= 1) {
      return incomeTx.length >= 2 ? 80.0 : 60.0;
    }

    // Calculate stability coefficient
    double sum = monthlyAmounts.values.reduce((a, b) => a + b);
    double mean = sum / monthlyAmounts.length;
    double varianceSum = monthlyAmounts.values.fold(0.0, (prev, val) => prev + pow(val - mean, 2));
    double standardDeviation = sqrt(varianceSum / monthlyAmounts.length);

    // High standard deviation relative to mean indicates instability
    double coefficient = mean > 0 ? standardDeviation / mean : 1.0;
    return max(0.0, 100.0 - (coefficient * 50.0));
  }

  static double calculateConsistencyScore(List<TransactionEntity> transactions) {
    final activeTx = transactions.where((tx) => !tx.isDeleted).toList();
    if (activeTx.isEmpty) return 10.0;

    // Consistency score is based on volume and distribution of transactions
    // Checks how many distinct weeks the user logged transactions
    final weeks = <String>{};
    for (final tx in activeTx) {
      final weekId = '${tx.date.year}-W${((tx.date.day - 1) / 7).floor()}';
      weeks.add(weekId);
    }

    double score = 40.0;
    if (weeks.length >= 4) {
      score += 40.0;
    } else if (weeks.length >= 2) {
      score += 20.0;
    }

    if (activeTx.length >= 15) {
      score += 20.0;
    } else if (activeTx.length >= 5) {
      score += 10.0;
    }

    return score.clamp(0.0, 100.0);
  }

  static double calculateOverallScore({
    required double savings,
    required double budget,
    required double cashFlow,
    required double expense,
    required double income,
    required double consistency,
  }) {
    // Weights: Savings 25%, Budget 20%, Cash Flow 20%, Expense 15%, Income 10%, Consistency 10%
    return (savings * 0.25) +
        (budget * 0.20) +
        (cashFlow * 0.20) +
        (expense * 0.15) +
        (income * 0.10) +
        (consistency * 0.10);
  }
}
