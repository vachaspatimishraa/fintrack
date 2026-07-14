import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/local/transaction_local_datasource.dart';
import '../datasources/remote/transaction_remote_datasource.dart';
import '../mappers/transaction_mapper.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_query_filter.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/entities/transaction_event_bus.dart';
import '../../../../core/database/isar/collections/transaction_model.dart';
import '../../../../core/database/isar/collections/account_model.dart';
import '../../../../core/services/sync_service.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDatasource _localDatasource;
  final TransactionRemoteDataSource _remoteDatasource;
  final SyncService _syncService;
  final SupabaseClient _supabase;
  final Isar _isar;
  final TransactionEventBus _eventBus = TransactionEventBus();

  TransactionRepositoryImpl({
    required TransactionLocalDatasource localDatasource,
    required TransactionRemoteDataSource remoteDatasource,
    required SyncService syncService,
    required SupabaseClient supabase,
    required Isar isar,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _syncService = syncService,
        _supabase = supabase,
        _isar = isar;

  // Reserved for sync engine usage
  TransactionRemoteDataSource get remoteDataSource => _remoteDatasource;

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    final userId = _supabase.auth.currentUser?.id;
    return _localDatasource.watchTransactions(userId).map(
          (models) => models.map((m) => TransactionMapper.toEntity(m)).toList(),
        );
  }

  @override
  Stream<TransactionEntity?> watchTransaction(String uuid) {
    return _isar.transactionModels
        .filter()
        .uuidEqualTo(uuid)
        .watch(fireImmediately: true)
        .map((models) => models.isEmpty ? null : TransactionMapper.toEntity(models.first));
  }

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions(int limit) {
    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    return _isar.transactionModels
        .filter()
        .userIdEqualTo(userId)
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .limit(limit)
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => TransactionMapper.toEntity(m)).toList());
  }

  @override
  Stream<List<TransactionEntity>> watchTransactionsByCategory(String category) {
    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    return _isar.transactionModels
        .filter()
        .userIdEqualTo(userId)
        .categoryEqualTo(category)
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => TransactionMapper.toEntity(m)).toList());
  }

  @override
  Stream<List<TransactionEntity>> watchTransactionsByDate(DateTime date) {
    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _isar.transactionModels
        .filter()
        .userIdEqualTo(userId)
        .dateBetween(startOfDay, endOfDay)
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => TransactionMapper.toEntity(m)).toList());
  }

  @override
  Stream<List<TransactionEntity>> watchDeletedTransactions() {
    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    return _isar.transactionModels
        .filter()
        .userIdEqualTo(userId)
        .isDeletedEqualTo(true)
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => TransactionMapper.toEntity(m)).toList());
  }

  @override
  Stream<List<TransactionEntity>> watchPendingSyncTransactions() {
    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    return _isar.transactionModels
        .filter()
        .userIdEqualTo(userId)
        .isSyncedEqualTo(false)
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => TransactionMapper.toEntity(m)).toList());
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final userId = _supabase.auth.currentUser?.id;
    final models = await _localDatasource.getTransactions(userId);
    return models.map((m) => TransactionMapper.toEntity(m)).toList();
  }

  @override
  Future<TransactionEntity?> getTransactionByUuid(String uuid) async {
    final model = await _localDatasource.getTransactionByUuid(uuid);
    if (model == null) return null;
    return TransactionMapper.toEntity(model);
  }

  @override
  Future<void> saveTransaction(TransactionEntity transaction) async {
    final isNew = transaction.uuid.isEmpty;
    final userId = _supabase.auth.currentUser?.id;

    final updatedTx = transaction.copyWith(
      uuid: isNew ? const Uuid().v4() : transaction.uuid,
      userId: userId,
      isSynced: false,
      createdAt: isNew ? DateTime.now() : transaction.createdAt,
      updatedAt: DateTime.now(),
    );

    final model = TransactionMapper.toModel(updatedTx);

    // Save to local database (Isar) first and update account balance
    await _isar.writeTxn(() async {
      if (!isNew) {
        final original =
            await _isar.transactionModels.filter().uuidEqualTo(model.uuid).findFirst();
        if (original != null) {
          final originalAccount =
              await _isar.accountModels.filter().uuidEqualTo(original.accountId).findFirst();
          if (originalAccount != null) {
            if (original.type == 'income') {
              originalAccount.balance -= original.amount;
            } else {
              originalAccount.balance += original.amount;
            }
            await _isar.accountModels.put(originalAccount);
          }
        }
      }

      final account =
          await _isar.accountModels.filter().uuidEqualTo(model.accountId).findFirst();
      if (account != null) {
        if (model.type == 'income') {
          account.balance += model.amount;
        } else {
          account.balance -= model.amount;
        }
        await _isar.accountModels.put(account);
      }

      await _isar.transactionModels.put(model);
    });

    assert(model.accountId.isNotEmpty);
    // Enqueue sync jobs in sync queue
    final account =
        await _isar.accountModels.filter().uuidEqualTo(model.accountId).findFirst();
    if (account != null) {
      await _syncService.queueSync(
        entityType: 'account',
        entityUuid: account.uuid,
        action: 'update',
        payload: account.toJson(),
      );
    }

    await _syncService.queueSync(
      entityType: 'transaction',
      entityUuid: model.uuid,
      action: isNew ? 'create' : 'update',
      payload: model.toJson(),
    );

    _eventBus.publish(TransactionEvent(
      type: isNew ? TransactionEventType.transactionCreated : TransactionEventType.transactionUpdated,
      transactionUuid: model.uuid,
      payload: model.toJson(),
    ));
  }

  @override
  Future<void> deleteTransaction(String uuid) async {
    final transaction = await _isar.transactionModels.filter().uuidEqualTo(uuid).findFirst();
    if (transaction != null) {
      // Soft delete locally
      await _isar.writeTxn(() async {
        transaction.isDeleted = true;
        transaction.isSynced = false;
        transaction.updatedAt = DateTime.now();

        final account =
            await _isar.accountModels.filter().uuidEqualTo(transaction.accountId).findFirst();
        if (account != null) {
          if (transaction.type == 'income') {
            account.balance -= transaction.amount;
          } else {
            account.balance += transaction.amount;
          }
          await _isar.accountModels.put(account);
        }
        await _isar.transactionModels.put(transaction);
      });

      assert(transaction.accountId.isNotEmpty);
      final account =
          await _isar.accountModels.filter().uuidEqualTo(transaction.accountId).findFirst();
      if (account != null) {
        await _syncService.queueSync(
          entityType: 'account',
          entityUuid: account.uuid,
          action: 'update',
          payload: account.toJson(),
        );
      }

      await _syncService.queueSync(
        entityType: 'transaction',
        entityUuid: uuid,
        action: 'delete',
        payload: {},
      );

      _eventBus.publish(TransactionEvent(
        type: TransactionEventType.transactionDeleted,
        transactionUuid: uuid,
      ));
    }
  }

  @override
  Future<void> restoreTransaction(String uuid) async {
    final transaction = await _isar.transactionModels.filter().uuidEqualTo(uuid).findFirst();
    if (transaction != null) {
      await _isar.writeTxn(() async {
        transaction.isDeleted = false;
        transaction.isSynced = false;
        transaction.updatedAt = DateTime.now();

        final account =
            await _isar.accountModels.filter().uuidEqualTo(transaction.accountId).findFirst();
        if (account != null) {
          if (transaction.type == 'income') {
            account.balance += transaction.amount;
          } else {
            account.balance -= transaction.amount;
          }
          await _isar.accountModels.put(account);
        }
        await _isar.transactionModels.put(transaction);
      });

      assert(transaction.accountId.isNotEmpty);
      final account =
          await _isar.accountModels.filter().uuidEqualTo(transaction.accountId).findFirst();
      if (account != null) {
        await _syncService.queueSync(
          entityType: 'account',
          entityUuid: account.uuid,
          action: 'update',
          payload: account.toJson(),
        );
      }

      await _syncService.queueSync(
        entityType: 'transaction',
        entityUuid: uuid,
        action: 'update',
        payload: transaction.toJson(),
      );

      _eventBus.publish(TransactionEvent(
        type: TransactionEventType.transactionRestored,
        transactionUuid: uuid,
        payload: transaction.toJson(),
      ));
    }
  }

  @override
  Future<List<TransactionEntity>> getDeletedTransactions() async {
    final userId = _supabase.auth.currentUser?.id;
    final List<TransactionModel> models;
    if (userId != null) {
      models = await _isar.transactionModels
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(true)
          .sortByDateDesc()
          .findAll();
    } else {
      models = await _isar.transactionModels
          .filter()
          .userIdIsNull()
          .isDeletedEqualTo(true)
          .sortByDateDesc()
          .findAll();
    }
    return models.map((m) => TransactionMapper.toEntity(m)).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsPaginated({
    required int limit,
    required int offset,
    required TransactionQueryFilter queryFilter,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    final models = await _localDatasource.getTransactionsPaginated(
      userId: userId,
      limit: limit,
      offset: offset,
      queryFilter: queryFilter,
    );
    return models.map((m) => TransactionMapper.toEntity(m)).toList();
  }
}
