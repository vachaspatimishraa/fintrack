import 'dart:io';
import '../../../../core/services/receipt_service.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class ReceiptReplacementService {
  final ReceiptService _receiptService;
  final TransactionRepository _transactionRepository;

  ReceiptReplacementService({
    required ReceiptService receiptService,
    required TransactionRepository transactionRepository,
  })  : _receiptService = receiptService,
        _transactionRepository = transactionRepository;

  Future<TransactionEntity> replaceReceipt({
    required TransactionEntity transaction,
    required File file,
  }) async {
    // Save image to local documents directory
    final localPath = await _receiptService.saveReceiptLocally(file);

    // Clone transaction with new local receipt reference
    final updatedTx = transaction.copyWith(
      receiptLocalPath: localPath,
      receiptUrl: null, // Reset to force cloud re-upload during sync
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    // Save changes to database
    await _transactionRepository.saveTransaction(updatedTx);
    return updatedTx;
  }

  Future<TransactionEntity> removeReceipt({
    required TransactionEntity transaction,
  }) async {
    // Clone transaction without receipt references
    final updatedTx = transaction.clearReceipt().copyWith(
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    // Save changes to database
    await _transactionRepository.saveTransaction(updatedTx);
    return updatedTx;
  }
}
