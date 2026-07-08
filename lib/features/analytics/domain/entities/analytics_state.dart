import '../../../transactions/domain/entities/transaction_entity.dart';

class AnalyticsState {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double savings;
  final List<TransactionEntity> recentTransactions;

  const AnalyticsState({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.savings,
    required this.recentTransactions,
  });

  factory AnalyticsState.empty() {
    return const AnalyticsState(
      totalBalance: 0.0,
      totalIncome: 0.0,
      totalExpense: 0.0,
      savings: 0.0,
      recentTransactions: [],
    );
  }
}
