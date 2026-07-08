import '../entities/transaction_dto.dart';

abstract class TransactionApi {
  Future<TransactionDto?> getTransactionDto(String uuid);
  Future<List<TransactionDto>> getRecentTransactionDtos(int limit);
}
