import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/transactions/domain/utils/duplicate_transaction_service.dart';
import 'package:fintrack/features/transactions/domain/utils/receipt_replacement_service.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fintrack/core/services/receipt_service.dart';

import 'package:fintrack/features/transactions/domain/entities/transaction_query_filter.dart';

class MockTransactionRepository implements TransactionRepository {
  TransactionEntity? savedTransaction;
  bool isDeletedCalled = false;
  bool isRestoredCalled = false;
  String? deletedUuid;
  String? restoredUuid;

  @override
  Stream<List<TransactionEntity>> watchTransactions() => const Stream.empty();

  @override
  Stream<TransactionEntity?> watchTransaction(String uuid) => const Stream.empty();

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions(int limit) => const Stream.empty();

  @override
  Stream<List<TransactionEntity>> watchTransactionsByCategory(String category) => const Stream.empty();

  @override
  Stream<List<TransactionEntity>> watchTransactionsByDate(DateTime date) => const Stream.empty();

  @override
  Stream<List<TransactionEntity>> watchDeletedTransactions() => const Stream.empty();

  @override
  Stream<List<TransactionEntity>> watchPendingSyncTransactions() => const Stream.empty();

  @override
  Future<List<TransactionEntity>> getTransactions() async => [];

  @override
  Future<TransactionEntity?> getTransactionByUuid(String uuid) async => null;

  @override
  Future<void> saveTransaction(TransactionEntity transaction) async {
    savedTransaction = transaction;
  }

  @override
  Future<void> deleteTransaction(String uuid) async {
    isDeletedCalled = true;
    deletedUuid = uuid;
  }

  @override
  Future<void> restoreTransaction(String uuid) async {
    isRestoredCalled = true;
    restoredUuid = uuid;
  }

  @override
  Future<List<TransactionEntity>> getDeletedTransactions() async => [];

  @override
  Future<List<TransactionEntity>> getTransactionsPaginated({
    required int limit,
    required int offset,
    required TransactionQueryFilter queryFilter,
  }) async => [];
}

class MockReceiptService implements ReceiptService {
  @override
  Future<File?> pickReceipt(any) async => null;

  @override
  Future<String> saveReceiptLocally(File file) async {
    return '/mock/local/path/receipt.png';
  }

  @override
  Future<String?> uploadReceipt(File file) async => null;
}

void main() {
  group('Transaction Lifecycle Workflow Extended Tests', () {
    late TransactionEntity dummyTx;

    setUp(() {
      dummyTx = TransactionEntity(
        uuid: 'tx-123',
        accountId: 'acc-111',
        type: 'expense',
        categoryId: 'Food',
        category: 'Food',
        amount: 25.50,
        title: 'Lunch',
        description: 'Tacos',
        currency: 'USD',
        paymentMethod: 'UPI',
        isDeleted: false,
        isSynced: true,
        isRecurring: false,
        date: DateTime(2026, 7, 3),
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
        syncVersion: 2,
      );
    });

    test('DuplicateTransactionService duplicates transaction properly', () {
      final duplicate = DuplicateTransactionService.duplicate(dummyTx);

      expect(duplicate.uuid, isNot(equals(dummyTx.uuid)));
      expect(duplicate.uuid, isNotEmpty);
      expect(duplicate.amount, equals(dummyTx.amount));
      expect(duplicate.title, equals(dummyTx.title));
      expect(duplicate.category, equals(dummyTx.category));
      expect(duplicate.paymentMethod, equals(dummyTx.paymentMethod));
      expect(duplicate.isSynced, isFalse);
      expect(duplicate.isDeleted, isFalse);
      expect(duplicate.syncVersion, equals(1));
    });

    test('ReceiptReplacementService replaceReceipt updates local path and saves', () async {
      final mockRepo = MockTransactionRepository();
      final mockReceiptService = MockReceiptService();
      final service = ReceiptReplacementService(
        receiptService: mockReceiptService,
        transactionRepository: mockRepo,
      );

      final updated = await service.replaceReceipt(
        transaction: dummyTx,
        file: File('any_file.png'),
      );

      expect(updated.receiptLocalPath, equals('/mock/local/path/receipt.png'));
      expect(updated.receiptUrl, isNull);
      expect(updated.isSynced, isFalse);
      expect(mockRepo.savedTransaction, isNotNull);
      expect(mockRepo.savedTransaction!.receiptLocalPath, equals('/mock/local/path/receipt.png'));
    });

    test('ReceiptReplacementService removeReceipt clears path and url and saves', () async {
      final mockRepo = MockTransactionRepository();
      final mockReceiptService = MockReceiptService();
      final service = ReceiptReplacementService(
        receiptService: mockReceiptService,
        transactionRepository: mockRepo,
      );

      final txWithReceipt = dummyTx.copyWith(
        receiptLocalPath: '/some/path/image.jpg',
        receiptUrl: 'https://supabase.storage/image.jpg',
      );

      final updated = await service.removeReceipt(transaction: txWithReceipt);

      expect(updated.receiptLocalPath, isNull);
      expect(updated.receiptUrl, isNull);
      expect(updated.isSynced, isFalse);
      expect(mockRepo.savedTransaction, isNotNull);
      expect(mockRepo.savedTransaction!.receiptLocalPath, isNull);
      expect(mockRepo.savedTransaction!.receiptUrl, isNull);
    });
  });
}
