import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/trash_repository.dart';

class TrashRepositoryImpl implements TrashRepository {
  final TransactionRepository _transactionRepository;

  TrashRepositoryImpl(this._transactionRepository);

  @override
  Future<List<TransactionEntity>> getDeletedTransactions() {
    return _transactionRepository.getDeletedTransactions();
  }

  @override
  Future<void> restoreTransaction(String uuid) {
    return _transactionRepository.restoreTransaction(uuid);
  }
}
