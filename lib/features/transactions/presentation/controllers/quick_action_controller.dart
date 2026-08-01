import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../accounts/providers/account_provider.dart';
import '../../../home/providers/home_provider.dart';
import '../../providers/transaction_provider.dart';

class QuickActionController {
  final Ref _ref;

  QuickActionController(this._ref);

  Future<void> executeSwipeLeft(BuildContext context, String uuid) async {
    final repo = _ref.read(transactionRepositoryProvider);
    await repo.deleteTransaction(uuid);
    _ref.invalidate(transactionsStreamProvider);
    _ref.invalidate(accountsStreamProvider);
    _ref.invalidate(allAccountsStreamProvider);
    _ref.invalidate(currentAccountModelProvider);
    _ref.invalidate(homeStateProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
    }
  }
}

final quickActionControllerProvider = Provider<QuickActionController>((ref) {
  return QuickActionController(ref);
});
