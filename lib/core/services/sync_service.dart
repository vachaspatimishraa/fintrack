import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isar/isar.dart';
import '../database/isar/collections/account_model.dart';
import '../database/isar/collections/transaction_model.dart';
import '../database/isar/collections/budget_model.dart';
import '../database/isar/collections/goal_model.dart';
import '../database/isar/collections/sync_queue_item.dart';
import '../network/connectivity_service.dart';

class SyncService {
  final Isar _isar;
  final ConnectivityService _connectivity;
  final SupabaseClient _supabase = Supabase.instance.client;

  final _pendingCountController = StreamController<int>.broadcast();
  final _syncStatusController = StreamController<bool>.broadcast();

  bool _isSyncing = false;
  StreamSubscription? _connectivitySubscription;

  SyncService({
    required Isar isar,
    required ConnectivityService connectivity,
  })  : _isar = isar,
        _connectivity = connectivity {
    _init();
  }

  Stream<int> get onPendingCountChanged => _pendingCountController.stream;
  Stream<bool> get onSyncStatusChanged => _syncStatusController.stream;

  void _init() {
    // Automatically trigger sync when connectivity is restored
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((connected) {
      if (connected) {
        triggerSync();
      }
    });

    // Send initial pending count
    _updatePendingCount();
  }

  Future<void> _updatePendingCount() async {
    final count = await _isar.syncQueueItems.count();
    _pendingCountController.add(count);
  }

  Future<void> queueSync({
    required String entityType,
    required String entityUuid,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final item = SyncQueueItem()
      ..entityType = entityType
      ..entityUuid = entityUuid
      ..action = action
      ..payload = jsonEncode(payload)
      ..createdAt = DateTime.now()
      ..retryCount = 0
      ..syncStatus = 'pending';

    await _isar.writeTxn(() async {
      await _isar.syncQueueItems.put(item);
    });

    await _updatePendingCount();
    triggerSync();
  }

  Future<void> resolveQueueItem(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.syncQueueItems.delete(id);
    });
    await _updatePendingCount();
  }

  Future<void> triggerSync() async {
    if (_isSyncing) return;

    final hasInternet = await _connectivity.checkConnection();
    if (!hasInternet) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return; // Guest mode - no sync to cloud

    _isSyncing = true;
    _syncStatusController.add(true);

    try {
      // 1. Process local mutations queued offline
      await _processSyncQueue(userId);

      // 2. Pull remote updates from Cloud
      await _pullFromCloud(userId);
    } catch (e) {
      debugPrint('Sync execution error: $e');
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
      await _updatePendingCount();
    }
  }

  Future<void> _processSyncQueue(String userId) async {
    final queueItems = await _isar.syncQueueItems
        .where()
        .filter()
        .not()
        .syncStatusEqualTo('processing')
        .sortByCreatedAt()
        .findAll();

    for (final item in queueItems) {
      if (item.retryCount >= 5) {
        await _isar.writeTxn(() async {
          item.syncStatus = 'failed';
          await _isar.syncQueueItems.put(item);
        });
        continue;
      }

      await _isar.writeTxn(() async {
        item.syncStatus = 'processing';
        await _isar.syncQueueItems.put(item);
      });

      final success = await _processQueueItem(item, userId);

      await _isar.writeTxn(() async {
        if (success) {
          await _isar.syncQueueItems.delete(item.id);
        } else {
          item.retryCount += 1;
          item.syncStatus = 'pending';
          await _isar.syncQueueItems.put(item);
        }
      });
    }
  }

  Future<bool> _processQueueItem(SyncQueueItem item, String userId) async {
    try {
      final payload = jsonDecode(item.payload) as Map<String, dynamic>;
      payload['user_id'] = userId;

      String table;
      switch (item.entityType) {
        case 'account':
          table = 'accounts';
          break;
        case 'transaction':
          table = 'transactions';
          break;
        case 'budget':
          table = 'budgets';
          break;
        case 'goal':
          table = 'goals';
          break;
        case 'category':
          table = 'categories';
          break;
        default:
          table = '${item.entityType}s';
      }

      if (item.action == 'delete') {
        await _supabase.from(table).delete().eq('id', item.entityUuid);
      } else {
        await _supabase.from(table).upsert(payload);
      }

      // Mark locally as synced
      await _markAsSyncedLocally(item.entityType, item.entityUuid, userId);
      
      return true;
    } catch (e) {
      debugPrint('Error processing sync queue item ${item.id} (${item.entityType}): $e');
      return false;
    }
  }

  Future<void> _markAsSyncedLocally(String entityType, String uuid, String userId) async {
    await _isar.writeTxn(() async {
      if (entityType == 'account') {
        final local = await _isar.accountModels.filter().uuidEqualTo(uuid).findFirst();
        if (local != null) {
          local.isSynced = true;
          local.userId = userId;
          await _isar.accountModels.put(local);
        }
      } else if (entityType == 'transaction') {
        final local = await _isar.transactionModels.filter().uuidEqualTo(uuid).findFirst();
        if (local != null) {
          local.isSynced = true;
          local.userId = userId;
          await _isar.transactionModels.put(local);
        }
      } else if (entityType == 'budget') {
        final local = await _isar.budgetModels.filter().uuidEqualTo(uuid).findFirst();
        if (local != null) {
          local.syncStatus = 'synced';
          local.ownerId = userId;
          await _isar.budgetModels.put(local);
        }
      } else if (entityType == 'goal') {
        final local = await _isar.goalModels.filter().uuidEqualTo(uuid).findFirst();
        if (local != null) {
          local.syncStatus = 'synced';
          local.ownerId = userId;
          await _isar.goalModels.put(local);
        }
      }
    });
  }

  Future<void> _pullFromCloud(String userId) async {
    try {
      // 1. Pull Accounts
      final accountsData = await _supabase.from('accounts').select().eq('user_id', userId);
      for (final item in accountsData) {
        final remoteAccount = AccountModel.fromJson(item);
        final localAccount = await _isar.accountModels.filter().uuidEqualTo(remoteAccount.uuid).findFirst();

        if (localAccount == null) {
          // New account from cloud
          await _isar.writeTxn(() async {
            await _isar.accountModels.put(remoteAccount);
          });
        } else {
          // Conflict Resolution: Latest updatedAt wins
          if (remoteAccount.updatedAt.isAfter(localAccount.updatedAt)) {
            debugPrint('Conflict resolved (Account): Remote wins for ${remoteAccount.name}');
            await _isar.writeTxn(() async {
              remoteAccount.id = localAccount.id;
              await _isar.accountModels.put(remoteAccount);
            });
          }
        }
      }

      // 2. Pull Transactions
      final transactionsData = await _supabase.from('transactions').select().eq('user_id', userId);
      for (final item in transactionsData) {
        final remoteTx = TransactionModel.fromJson(item);
        final localTx = await _isar.transactionModels.filter().uuidEqualTo(remoteTx.uuid).findFirst();

        if (localTx == null) {
          // New transaction from cloud
          await _isar.writeTxn(() async {
            await _isar.transactionModels.put(remoteTx);
          });
        } else {
          // Conflict Resolution: Latest updatedAt wins
          if (remoteTx.updatedAt.isAfter(localTx.updatedAt)) {
            debugPrint('Conflict resolved (Transaction): Remote wins for transaction ${remoteTx.uuid}');
            await _isar.writeTxn(() async {
              remoteTx.id = localTx.id;
              await _isar.transactionModels.put(remoteTx);
            });
          }
        }
      }

      // 3. Pull Budgets
      final budgetsData = await _supabase.from('budgets').select().eq('user_id', userId);
      for (final item in budgetsData) {
        final remoteBudget = BudgetModel.fromJson(item);
        final localBudget = await _isar.budgetModels.filter().uuidEqualTo(remoteBudget.uuid).findFirst();

        if (localBudget == null) {
          await _isar.writeTxn(() async {
            await _isar.budgetModels.put(remoteBudget);
          });
        } else if (remoteBudget.updatedAt.isAfter(localBudget.updatedAt)) {
          await _isar.writeTxn(() async {
            remoteBudget.id = localBudget.id;
            await _isar.budgetModels.put(remoteBudget);
          });
        }
      }

      // 4. Pull Goals
      final goalsData = await _supabase.from('goals').select().eq('user_id', userId);
      for (final item in goalsData) {
        final remoteGoal = GoalModel.fromJson(item);
        final localGoal = await _isar.goalModels.filter().uuidEqualTo(remoteGoal.uuid).findFirst();

        if (localGoal == null) {
          await _isar.writeTxn(() async {
            await _isar.goalModels.put(remoteGoal);
          });
        } else if (remoteGoal.updatedAt.isAfter(localGoal.updatedAt)) {
          await _isar.writeTxn(() async {
            remoteGoal.id = localGoal.id;
            await _isar.goalModels.put(remoteGoal);
          });
        }
      }
    } catch (e) {
      debugPrint('Cloud pull synchronization error: $e');
    }
  }

  Future<void> migrateGuestData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Load guest data (where userId is null or empty)
    final guestAccounts = await _isar.accountModels.filter().userIdIsNull().findAll();
    for (final account in guestAccounts) {
      await _isar.writeTxn(() async {
        account.userId = userId;
        account.isSynced = false;
        await _isar.accountModels.put(account);
      });
      await queueSync(
        entityType: 'account',
        entityUuid: account.uuid,
        action: 'create',
        payload: account.toJson(),
      );
    }

    final guestTransactions = await _isar.transactionModels.filter().userIdIsNull().findAll();
    for (final tx in guestTransactions) {
      await _isar.writeTxn(() async {
        tx.userId = userId;
        tx.isSynced = false;
        await _isar.transactionModels.put(tx);
      });
      await queueSync(
        entityType: 'transaction',
        entityUuid: tx.uuid,
        action: 'create',
        payload: tx.toJson(),
      );
    }

    // Force trigger sync to upload guest changes immediately
    triggerSync();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _pendingCountController.close();
    _syncStatusController.close();
  }
}
