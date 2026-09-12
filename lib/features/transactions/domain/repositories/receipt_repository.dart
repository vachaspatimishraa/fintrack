import 'dart:io';
import 'package:fintrack/core/database/isar/collections/receipt_model.dart';

abstract class ReceiptRepository {
  Future<ReceiptModel?> getReceiptByTransactionId(String transactionId);
  Future<void> saveReceipt(ReceiptModel receipt);
  Future<void> deleteReceipt(String uuid);
  Future<ReceiptModel> compressAndSaveReceiptLocally(String transactionId, File file);
  Future<void> uploadReceipt(String uuid);
}
