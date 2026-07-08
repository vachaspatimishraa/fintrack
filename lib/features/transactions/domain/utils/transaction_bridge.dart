import '../repositories/transaction_api.dart';
import '../repositories/transaction_repository.dart';
import '../entities/transaction_dto.dart';

class TransactionBridge implements TransactionApi {
  final TransactionRepository _repository;

  TransactionBridge(this._repository);

  @override
  Future<TransactionDto?> getTransactionDto(String uuid) async {
    final tx = await _repository.getTransactionByUuid(uuid);
    if (tx == null) return null;
    return TransactionDto(
      uuid: tx.uuid,
      accountId: tx.accountId,
      type: tx.type,
      categoryId: tx.categoryId,
      category: tx.category,
      amount: tx.amount,
      title: tx.title,
      currency: tx.currency,
      paymentMethod: tx.paymentMethod,
      date: tx.date,
    );
  }

  @override
  Future<List<TransactionDto>> getRecentTransactionDtos(int limit) async {
    final list = await _repository.getTransactions();
    final sorted = List.of(list)..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).map((tx) {
      return TransactionDto(
        uuid: tx.uuid,
        accountId: tx.accountId,
        type: tx.type,
        categoryId: tx.categoryId,
        category: tx.category,
        amount: tx.amount,
        title: tx.title,
        currency: tx.currency,
        paymentMethod: tx.paymentMethod,
        date: tx.date,
      );
    }).toList();
  }
}
