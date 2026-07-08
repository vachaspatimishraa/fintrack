import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/utils/duplicate_transaction_service.dart';
import '../../providers/transaction_provider.dart';

class TransactionController {
  final Ref _ref;

  TransactionController(this._ref);

  Future<void> saveTransaction(TransactionEntity transaction) {
    return _ref.read(transactionRepositoryProvider).saveTransaction(transaction);
  }

  Future<void> deleteTransaction(String uuid) {
    return _ref.read(transactionRepositoryProvider).deleteTransaction(uuid);
  }

  Future<void> restoreTransaction(String uuid) {
    return _ref.read(transactionRepositoryProvider).restoreTransaction(uuid);
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
