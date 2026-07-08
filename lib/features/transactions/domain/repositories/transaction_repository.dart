import '../entities/transaction_entity.dart';
import '../entities/transaction_query_filter.dart';

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> watchTransactions();
  Stream<TransactionEntity?> watchTransaction(String uuid);
  Stream<List<TransactionEntity>> watchRecentTransactions(int limit);
  Stream<List<TransactionEntity>> watchTransactionsByCategory(String category);
  Stream<List<TransactionEntity>> watchTransactionsByDate(DateTime date);
  Stream<List<TransactionEntity>> watchDeletedTransactions();
  Stream<List<TransactionEntity>> watchPendingSyncTransactions();

  Future<List<TransactionEntity>> getTransactions();
  Future<TransactionEntity?> getTransactionByUuid(String uuid);
  Future<void> saveTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String uuid);
  Future<void> restoreTransaction(String uuid);
  Future<List<TransactionEntity>> getDeletedTransactions();
  Future<List<TransactionEntity>> getTransactionsPaginated({
    required int limit,
    required int offset,
    required TransactionQueryFilter queryFilter,
  });
}
