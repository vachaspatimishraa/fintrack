import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/isar/collections/receipt_model.dart';
import '../../providers/transaction_provider.dart';

class ReceiptController {
  final Ref _ref;

  ReceiptController(this._ref);

  Future<ReceiptModel?> getReceiptByTransactionId(String transactionId) {
    return _ref.read(receiptRepositoryProvider).getReceiptByTransactionId(transactionId);
  }

  Future<ReceiptModel> attachReceipt(String transactionId, File file) {
    return _ref.read(receiptRepositoryProvider).compressAndSaveReceiptLocally(transactionId, file);
  }

  Future<void> deleteReceipt(String uuid) {
    return _ref.read(receiptRepositoryProvider).deleteReceipt(uuid);
  }
}

final receiptControllerProvider = Provider<ReceiptController>((ref) {
  return ReceiptController(ref);
});
