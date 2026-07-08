import '../../domain/entities/transaction_entity.dart';

abstract class TrashRepository {
  Future<List<TransactionEntity>> getDeletedTransactions();
  Future<void> restoreTransaction(String uuid);
}
