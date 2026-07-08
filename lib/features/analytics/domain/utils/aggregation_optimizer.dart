import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/monthly_report_data.dart';

class AggregationOptimizer {
  const AggregationOptimizer._();

  static MonthlySummary incrementalUpdate({
    required MonthlySummary currentSummary,
    required TransactionEntity updatedTransaction,
    required String action, // 'create', 'update', 'delete'
    TransactionEntity? oldTransaction, // required for 'update'
  }) {
    double incomeDiff = 0.0;
    double expenseDiff = 0.0;

    if (action == 'create') {
      if (updatedTransaction.type == 'income') {
        incomeDiff = updatedTransaction.amount;
      } else if (updatedTransaction.type == 'expense') {
        expenseDiff = updatedTransaction.amount;
      }
    } else if (action == 'delete') {
      if (updatedTransaction.type == 'income') {
        incomeDiff = -updatedTransaction.amount;
      } else if (updatedTransaction.type == 'expense') {
        expenseDiff = -updatedTransaction.amount;
      }
    } else if (action == 'update' && oldTransaction != null) {
      // Subtract old transaction value
      if (oldTransaction.type == 'income') {
        incomeDiff -= oldTransaction.amount;
      } else if (oldTransaction.type == 'expense') {
        expenseDiff -= oldTransaction.amount;
      }
      // Add new transaction value
      if (updatedTransaction.type == 'income') {
        incomeDiff += updatedTransaction.amount;
      } else if (updatedTransaction.type == 'expense') {
        expenseDiff += updatedTransaction.amount;
      }
    }

    final newIncome = currentSummary.income + incomeDiff;
    final newExpense = currentSummary.expense + expenseDiff;

    return MonthlySummary(
      income: newIncome,
      expense: newExpense,
      savings: newIncome - newExpense,
      cashFlow: newIncome - newExpense,
    );
  }
}
