import '../../domain/entities/transaction_entity.dart';

class TransactionVersionManager {
  static TransactionEntity incrementVersion(TransactionEntity tx) {
    return tx.copyWith(
      syncVersion: tx.syncVersion + 1,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
  }
}
