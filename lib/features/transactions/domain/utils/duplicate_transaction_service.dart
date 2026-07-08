import 'package:uuid/uuid.dart';
import '../entities/transaction_entity.dart';

class DuplicateTransactionService {
  static TransactionEntity duplicate(TransactionEntity original) {
    return original.copyWith(
      uuid: const Uuid().v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      isDeleted: false,
      syncVersion: 1,
    );
  }
}
