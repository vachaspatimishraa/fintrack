import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../accounts/providers/account_provider.dart';
import '../../../home/providers/home_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/utils/duplicate_transaction_service.dart';
import '../../providers/transaction_provider.dart';

class TransactionController {
  final Ref _ref;

  TransactionController(this._ref);

  void _invalidateProviders() {
    _ref.invalidate(transactionsStreamProvider);
    _ref.invalidate(accountsStreamProvider);
    _ref.invalidate(allAccountsStreamProvider);
    _ref.invalidate(currentAccountModelProvider);
    _ref.invalidate(homeStateProvider);
  }

  Future<void> saveTransaction(TransactionEntity transaction) async {
    await _ref.read(transactionRepositoryProvider).saveTransaction(transaction);
    _invalidateProviders();
  }

  Future<void> deleteTransaction(String uuid) async {
    await _ref.read(transactionRepositoryProvider).deleteTransaction(uuid);
    _invalidateProviders();
  }

  Future<void> restoreTransaction(String uuid) async {
    await _ref.read(transactionRepositoryProvider).restoreTransaction(uuid);
    _invalidateProviders();
  }

  TransactionEntity duplicateTransaction(TransactionEntity transaction) {
    return DuplicateTransactionService.duplicate(transaction);
  }

  Future<TransactionEntity> replaceReceipt(TransactionEntity transaction, File file) {
    return _ref.read(receiptReplacementServiceProvider).replaceReceipt(
      transaction: transaction,
      file: file,
    );
  }

  Future<TransactionEntity> removeReceipt(TransactionEntity transaction) {
    return _ref.read(receiptReplacementServiceProvider).removeReceipt(
      transaction: transaction,
    );
  }
}

final transactionControllerProvider =
    Provider<TransactionController>((ref) => TransactionController(ref));
