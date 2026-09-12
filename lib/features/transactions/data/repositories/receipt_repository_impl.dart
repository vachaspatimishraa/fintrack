import 'dart:io';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:fintrack/core/database/isar/collections/receipt_model.dart';
import 'package:fintrack/core/database/isar/collections/transaction_model.dart';
import 'package:fintrack/features/transactions/domain/repositories/receipt_repository.dart';
import 'package:fintrack/features/transactions/domain/utils/image_validator.dart';
import 'package:fintrack/features/transactions/domain/utils/receipt_compression_service.dart';
import 'package:fintrack/features/transactions/domain/utils/receipt_cache_service.dart';
import 'package:fintrack/features/transactions/domain/utils/receipt_storage_service.dart';
import 'package:fintrack/core/services/sync_service.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final Isar _isar;
  final SupabaseClient _supabase;
  final SyncService _syncService;
  final ReceiptCacheService cacheService;
  final ReceiptStorageService _storageService;

  ReceiptRepositoryImpl({
    required Isar isar,
    required SupabaseClient supabase,
    required SyncService syncService,
    required this.cacheService,
    required ReceiptStorageService storageService,
  })  : _isar = isar,
        _supabase = supabase,
        _syncService = syncService,
        _storageService = storageService;

  @override
  Future<ReceiptModel?> getReceiptByTransactionId(String transactionId) {
    return _isar.receiptModels.filter().transactionIdEqualTo(transactionId).isDeletedEqualTo(false).findFirst();
  }

  @override
  Future<void> saveReceipt(ReceiptModel receipt) async {
    await _isar.writeTxn(() async {
      await _isar.receiptModels.put(receipt);
    });
  }

  @override
  Future<void> deleteReceipt(String uuid) async {
    final receipt = await _isar.receiptModels.filter().uuidEqualTo(uuid).findFirst();
    if (receipt != null) {
      // 1. Delete local file if it exists
      try {
        final file = File(receipt.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      // 2. Soft delete in DB
      await _isar.writeTxn(() async {
        receipt.isDeleted = true;
        receipt.updatedAt = DateTime.now();
        await _isar.receiptModels.put(receipt);
      });

      // 3. Queue cloud deletion
      if (receipt.cloudUrl != null) {
        await _storageService.deleteReceipt(receipt.cloudUrl!);
      }

      await _syncService.queueSync(
        entityType: 'receipt',
        entityUuid: uuid,
        action: 'delete',
        payload: {},
      );
    }
  }

  @override
  Future<ReceiptModel> compressAndSaveReceiptLocally(String transactionId, File file) async {
    final validationError = ImageValidator.validate(file);
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final compressed = await ReceiptCompressionService.compress(file);
    final uuid = const Uuid().v4();
    final localPath = file.path;

    final size = await compressed.length();
    final receipt = ReceiptModel()
      ..uuid = uuid
      ..transactionId = transactionId
      ..localPath = localPath
      ..cloudUrl = null
      ..mimeType = file.path.endsWith('.png') ? 'image/png' : 'image/jpeg'
      ..fileSize = size
      ..width = 1024
      ..height = 1024
      ..isUploaded = false
      ..isDeleted = false
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await saveReceipt(receipt);

    // Queue sync upload
    await _syncService.queueSync(
      entityType: 'receipt',
      entityUuid: receipt.uuid,
      action: 'create',
      payload: receipt.toJson(),
    );

    return receipt;
  }

  @override
  Future<void> uploadReceipt(String uuid) async {
    final receipt = await _isar.receiptModels.filter().uuidEqualTo(uuid).findFirst();
    if (receipt == null || receipt.isUploaded || receipt.isDeleted) return;

    final file = File(receipt.localPath);
    if (!await file.exists()) return;

    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    final tx = await _isar.transactionModels.filter().uuidEqualTo(receipt.transactionId).findFirst();
    final accountId = tx?.accountId ?? 'wallet';
    final date = tx?.date ?? DateTime.now();

    final cloudUrl = await _storageService.uploadReceipt(
      file: file,
      userId: userId,
      accountId: accountId,
      date: date,
      transactionUuid: receipt.transactionId,
    );

    if (cloudUrl != null) {
      await _isar.writeTxn(() async {
        receipt.cloudUrl = cloudUrl;
        receipt.isUploaded = true;
        receipt.updatedAt = DateTime.now();
        await _isar.receiptModels.put(receipt);
      });

      // Update sync queue entry status or send payload update
      await _syncService.queueSync(
        entityType: 'receipt',
        entityUuid: uuid,
        action: 'update',
        payload: receipt.toJson(),
      );
    }
  }
}
