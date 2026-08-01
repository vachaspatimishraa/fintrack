import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../accounts/providers/account_provider.dart';
import '../../../home/providers/home_provider.dart';
import '../../providers/transaction_provider.dart';

class BulkTransactionController {
  final Ref _ref;

  BulkTransactionController(this._ref);

  void _invalidateProviders() {
    _ref.invalidate(transactionsStreamProvider);
    _ref.invalidate(accountsStreamProvider);
    _ref.invalidate(allAccountsStreamProvider);
    _ref.invalidate(currentAccountModelProvider);
    _ref.invalidate(homeStateProvider);
  }

  Future<void> bulkDelete(List<String> uuids) async {
    final repo = _ref.read(transactionRepositoryProvider);
    for (final uuid in uuids) {
      await repo.deleteTransaction(uuid);
    }
    _invalidateProviders();
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
    _invalidateProviders();
  }
}

final bulkTransactionControllerProvider = Provider<BulkTransactionController>((ref) {
  return BulkTransactionController(ref);
});
