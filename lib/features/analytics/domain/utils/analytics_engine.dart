import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/analytics_state.dart';

class AnalyticsEngine {
  static AnalyticsState calculateState(List<TransactionEntity> transactions) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (final tx in transactions) {
      if (tx.isDeleted) continue;
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'expense') {
        totalExpense += tx.amount;
      }
    }

    final savings = totalIncome - totalExpense;
    final totalBalance = savings;

    final sorted = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recent = sorted.take(5).toList();

    return AnalyticsState(
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      savings: savings,
      recentTransactions: recent,
    );
  }
}
