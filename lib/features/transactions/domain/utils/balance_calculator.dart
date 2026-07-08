import '../entities/transaction_entity.dart';

class BalanceCalculator {
  static double calculateTotalBalance(List<TransactionEntity> transactions, double openingBalance) {
    double balance = openingBalance;
    for (final tx in transactions) {
      if (tx.isDeleted) continue;
      if (tx.type == 'income') {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  static double calculateIncome(List<TransactionEntity> transactions) {
    return transactions
        .where((tx) => !tx.isDeleted && tx.type == 'income')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  static double calculateExpense(List<TransactionEntity> transactions) {
    return transactions
        .where((tx) => !tx.isDeleted && tx.type == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
}
