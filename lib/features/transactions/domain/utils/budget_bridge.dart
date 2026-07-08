import '../../domain/entities/transaction_entity.dart';

class BudgetBridge {
  static void notifyBudgetUpdate(TransactionEntity tx) {
    print('[BUDGET BRIDGE]: Notified transaction update for UUID: ${tx.uuid}');
  }
}
