import '../../domain/entities/transaction_entity.dart';

enum ConflictResolutionAction { uploadLocal, downloadCloud, noAction }

class ConflictResolver {
  static ConflictResolutionAction resolve({
    required TransactionEntity local,
    required TransactionEntity remote,
  }) {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      return ConflictResolutionAction.uploadLocal;
    } else if (remote.updatedAt.isAfter(local.updatedAt)) {
      return ConflictResolutionAction.downloadCloud;
    }
    return ConflictResolutionAction.noAction;
  }
}
