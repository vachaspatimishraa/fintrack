import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_provider.dart';

class BulkTransactionController {
  final Ref _ref;

  BulkTransactionController(this._ref);

  Future<void> bulkDelete(List<String> uuids) async {
    final repo = _ref.read(transactionRepositoryProvider);
    for (final uuid in uuids) {
      await repo.deleteTransaction(uuid);
    }
  }

  Future<void> bulkUpdateCategory(List<String> uuids, String category) async {
    final repo = _ref.read(transactionRepositoryProvider);
    for (final uuid in uuids) {
      final tx = await repo.getTransactionByUuid(uuid);
      if (tx != null) {
        await repo.saveTransaction(tx.copyWith(
          categoryId: category,
          category: category,
        ));
      }
    }
  }
}

final bulkTransactionControllerProvider = Provider<BulkTransactionController>((ref) {
  return BulkTransactionController(ref);
});
