import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/database/isar/collections/sync_queue_item.dart';
import '../../../../core/database/isar/collections/transaction_model.dart';
import '../../../../core/services/sync_service.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/utils/conflict_resolver.dart';
import '../datasources/remote/transaction_sync_adapter.dart';

class SyncCoordinator {
  final Isar _isar;
  final SupabaseClient _supabase;
  final SyncService _syncService;

  SyncCoordinator({
    required Isar isar,
    required SupabaseClient supabase,
    required SyncService syncService,
  })  : _isar = isar,
        _supabase = supabase,
        _syncService = syncService;

  Future<void> runSync() async {
    // 1. Get all pending sync items from Isar via SyncService
    final queueItems = await _isar.syncQueueItems
        .filter()
        .syncStatusEqualTo('pending')
        .sortByCreatedAt()
        .findAll();

    for (final item in queueItems) {
      try {
        await _processQueueItem(item);
      } catch (e) {
        // Increment retry count
        await _isar.writeTxn(() async {
          item.retryCount += 1;
          if (item.retryCount >= 5) {
            item.syncStatus = 'failed';
          }
          await _isar.syncQueueItems.put(item);
        });
      }
    }
  }

  Future<void> _processQueueItem(SyncQueueItem item) async {
    final payload = item.payload;
    if (item.entityType == 'transaction') {
      if (item.action == 'create' || item.action == 'update') {
        final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
        final tx = TransactionSyncAdapter.fromSupabasePayload(payloadMap);
        
        // Fetch remote record to check conflicts
        final remoteRes = await _supabase
            .from('transactions')
            .select()
            .eq('id', tx.uuid)
            .maybeSingle();

        if (remoteRes != null) {
          final remoteTx = TransactionSyncAdapter.fromSupabasePayload(remoteRes);
          final resolution = ConflictResolver.resolve(local: tx, remote: remoteTx);

          if (resolution == ConflictResolutionAction.downloadCloud) {
            // Remote wins: update local Isar database
            final model = TransactionModel.fromJson(remoteRes);
            await _isar.writeTxn(() async {
              await _isar.transactionModels.put(model);
            });
            await _syncService.resolveQueueItem(item.id);
            return;
          }
        }

        // Upload local changes
        await _supabase.from('transactions').upsert(payload);
      } else if (item.action == 'delete') {
        await _supabase.from('transactions').delete().eq('id', item.entityUuid);
      }
    }

    await _syncService.resolveQueueItem(item.id);
  }

  Future<void> migrateGuestData(String newUserId) async {
    // Updgrade guest transactions to the logged in userId
    final localTransactions = await _isar.transactionModels
        .filter()
        .userIdEqualTo('guest')
        .findAll();

    await _isar.writeTxn(() async {
      for (final tx in localTransactions) {
        tx.userId = newUserId;
        tx.isSynced = false;
        tx.updatedAt = DateTime.now();
        await _isar.transactionModels.put(tx);

        final entity = TransactionEntity(
          uuid: tx.uuid,
          accountId: tx.accountId,
          type: tx.type,
          categoryId: tx.categoryId,
          category: tx.category,
          amount: tx.amount,
          title: tx.title,
          description: tx.description,
          currency: tx.currency,
          paymentMethod: tx.paymentMethod,
          isDeleted: tx.isDeleted,
          isSynced: tx.isSynced,
          isRecurring: tx.isRecurring,
          date: tx.date,
          createdAt: tx.createdAt,
          updatedAt: tx.updatedAt,
          syncVersion: tx.syncVersion,
        );

        // Queue upload for each migrated transaction
        await _syncService.queueSync(
          entityType: 'transaction',
          entityUuid: tx.uuid,
          action: 'create',
          payload: TransactionSyncAdapter.toSupabasePayload(entity),
        );
      }
    });

    // Run synchronization immediately
    await runSync();
  }
}
