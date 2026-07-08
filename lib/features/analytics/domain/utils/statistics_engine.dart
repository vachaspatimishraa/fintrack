import 'dart:math';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/custom_report_data.dart';

class StatisticsEngine {
  const StatisticsEngine._();

  static CustomReportStats calculate(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return CustomReportStats.zero();

    double income = 0.0;
    double expense = 0.0;
    double largestTransaction = 0.0;
    double totalAmount = 0.0;

    for (final tx in transactions) {
      if (tx.type == 'income') {
        income += tx.amount;
      } else if (tx.type == 'expense') {
        expense += tx.amount;
      }

      totalAmount += tx.amount;
      largestTransaction = max(largestTransaction, tx.amount);
    }

    final averageTransaction = transactions.isEmpty ? 0.0 : totalAmount / transactions.length;

    // Default compliance calculation for custom filters:
    // If savings rate (savings/income) is positive, compliance is high.
    double complianceScore = 100.0;
    if (income > 0) {
      final savingsRate = (income - expense) / income;
      if (savingsRate < 0) {
        complianceScore = max(0.0, 100.0 + (savingsRate * 100.0));
      }
    } else {
      if (expense > 0) {
        complianceScore = 30.0; // Needs attention
      }
    }

    return CustomReportStats(
      income: income,
      expense: expense,
      savings: income - expense,
      cashFlow: income - expense,
      averageTransaction: averageTransaction,
      largestTransaction: largestTransaction,
      transactionCount: transactions.length,
      budgetUtilization: income > 0 ? (expense / income).clamp(0.0, 1.0) : 0.0,
      complianceScore: complianceScore.clamp(0.0, 100.0),
    );
  }
}
