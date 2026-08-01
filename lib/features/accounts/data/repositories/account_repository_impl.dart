import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/local/account_local_datasource.dart';
import '../datasources/remote/account_remote_datasource.dart';
import '../../../../core/database/isar/collections/account_model.dart';
import '../../../../core/services/sync_service.dart';
import '../../domain/utils/conflict_resolver.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDatasource _localDatasource;
  final AccountRemoteDataSource _remoteDatasource;
  final SyncService _syncService;
  final SupabaseClient _supabase;

  AccountRepositoryImpl({
    required AccountLocalDatasource localDatasource,
    required AccountRemoteDataSource remoteDatasource,
    required SyncService syncService,
    required SupabaseClient supabase,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _syncService = syncService,
        _supabase = supabase;

  @override
  Stream<List<AccountModel>> watchAccounts() {
    final userId = _supabase.auth.currentUser?.id;
    return _localDatasource.watchAccounts(userId);
  }

  @override
  Stream<List<AccountModel>> watchAllAccounts() {
    final userId = _supabase.auth.currentUser?.id;
    return _localDatasource.watchAllAccounts(userId);
  }

  @override
  Stream<List<AccountModel>> watchEverything() {
    final userId = _supabase.auth.currentUser?.id;
    return _localDatasource.watchEverything(userId);
  }

  @override
  Future<List<AccountModel>> getAccounts() async {
    final userId = _supabase.auth.currentUser?.id;
    return _localDatasource.getAccounts(userId);
  }

  @override
  Future<List<AccountModel>> getAllActiveAccounts() async {
    final userId = _supabase.auth.currentUser?.id;
    return _localDatasource.getAllActiveAccounts(userId);
  }

  @override
  Future<List<AccountModel>> getEverything() async {
    final userId = _supabase.auth.currentUser?.id;
    return _localDatasource.getEverything(userId);
  }

  @override
  Future<AccountModel?> getAccountByUuid(String uuid) {
    return _localDatasource.getAccountByUuid(uuid);
  }

  @override
  Future<void> saveAccount(AccountModel account) async {
    try {
      final isNew = account.uuid.isEmpty;
      if (isNew) {
        account.uuid = const Uuid().v4();
        account.createdAt = DateTime.now();
      }
      account.updatedAt = DateTime.now();
      account.userId = _supabase.auth.currentUser?.id;
      account.isSynced = false;

      debugPrint("Saving account: ${account.name} (UUID: ${account.uuid}, isNew: $isNew)");

      await _localDatasource.putAccount(account);

      debugPrint("Local save successful. Queueing sync.");

      // ignore: unawaited_futures
      _syncService.queueSync(
        entityType: 'account',
        entityUuid: account.uuid,
        action: isNew ? 'create' : 'update',
        payload: account.toJson(),
      ).catchError((e) {
        debugPrint("Sync queue failed for account: $e");
      });
    } catch (e, stackTrace) {
      debugPrint("ACCOUNT REPOSITORY SAVE FAILED");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String uuid) async {
    final account = await _localDatasource.getAccountByUuid(uuid);
    if (account != null) {
      account.isDeleted = true;
      account.updatedAt = DateTime.now();
      account.isSynced = false;

      await _localDatasource.putAccount(account);

      await _syncService.queueSync(
        entityType: 'account',
        entityUuid: uuid,
        action: 'update',
        payload: account.toJson(),
      );
    }
  }

  @override
  Future<void> archiveAccount(String uuid, bool archive) async {
    final account = await _localDatasource.getAccountByUuid(uuid);
    if (account != null) {
      account.isArchived = archive;
      account.updatedAt = DateTime.now();
      account.isSynced = false;

      await _localDatasource.putAccount(account);

      await _syncService.queueSync(
        entityType: 'account',
        entityUuid: uuid,
        action: 'update',
        payload: account.toJson(),
      );
    }
  }

  @override
  Future<void> restoreAccount(String uuid) async {
    final account = await _localDatasource.getAccountByUuid(uuid);
    if (account != null) {
      account.isDeleted = false;
      account.isArchived = false;
      account.updatedAt = DateTime.now();
      account.isSynced = false;

      await _localDatasource.putAccount(account);

      await _syncService.queueSync(
        entityType: 'account',
        entityUuid: uuid,
        action: 'update',
        payload: account.toJson(),
      );
    }
  }

  @override
  Future<void> syncAccounts() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final remotePayloads = await _remoteDatasource.fetchAccounts(userId);
    for (final payload in remotePayloads) {
      final remoteAccount = AccountModel.fromJson(payload);
      final localAccount = await _localDatasource.getAccountByUuid(remoteAccount.uuid);

      if (localAccount == null) {
        if (!remoteAccount.isDeleted) {
          await _localDatasource.putAccount(remoteAccount);
        }
      } else {
        if (remoteAccount.isDeleted) {
          localAccount.isDeleted = true;
          localAccount.updatedAt = DateTime.now();
          await _localDatasource.putAccount(localAccount);
        } else {
          final resolution = ConflictResolver.resolve(local: localAccount, remote: remoteAccount);
          if (resolution == ConflictResolutionResult.remoteWins) {
            remoteAccount.id = localAccount.id;
            await _localDatasource.putAccount(remoteAccount);
          } else if (resolution == ConflictResolutionResult.localWins) {
            await _remoteDatasource.upsertAccount(localAccount.toJson());
          }
        }
      }
    }
  }
}
