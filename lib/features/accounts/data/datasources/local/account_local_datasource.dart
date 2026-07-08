import 'package:isar/isar.dart';
import '../../../../../core/database/isar/collections/account_model.dart';

class AccountLocalDatasource {
  final Isar _isar;

  AccountLocalDatasource(this._isar);

  Stream<List<AccountModel>> watchAccounts(String? userId) {
    if (userId != null) {
      return _isar.accountModels
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .isArchivedEqualTo(false)
          .watch(fireImmediately: true);
    } else {
      return _isar.accountModels
          .filter()
          .userIdIsNull()
          .isDeletedEqualTo(false)
          .isArchivedEqualTo(false)
          .watch(fireImmediately: true);
    }
  }

  Stream<List<AccountModel>> watchAllAccounts(String? userId) {
    if (userId != null) {
      return _isar.accountModels
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } else {
      return _isar.accountModels
          .filter()
          .userIdIsNull()
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    }
  }

  Future<List<AccountModel>> getAccounts(String? userId) async {
    if (userId != null) {
      return _isar.accountModels
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .isArchivedEqualTo(false)
          .findAll();
    } else {
      return _isar.accountModels
          .filter()
          .userIdIsNull()
          .isDeletedEqualTo(false)
          .isArchivedEqualTo(false)
          .findAll();
    }
  }

  Future<List<AccountModel>> getAllActiveAccounts(String? userId) async {
    if (userId != null) {
      return _isar.accountModels
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .findAll();
    } else {
      return _isar.accountModels
          .filter()
          .userIdIsNull()
          .isDeletedEqualTo(false)
          .findAll();
    }
  }

  Future<AccountModel?> getAccountByUuid(String uuid) {
    return _isar.accountModels.filter().uuidEqualTo(uuid).findFirst();
  }

  Stream<List<AccountModel>> watchEverything(String? userId) {
    if (userId != null) {
      return _isar.accountModels
          .filter()
          .userIdEqualTo(userId)
          .watch(fireImmediately: true);
    } else {
      return _isar.accountModels
          .filter()
          .userIdIsNull()
          .watch(fireImmediately: true);
    }
  }

  Future<List<AccountModel>> getEverything(String? userId) async {
    if (userId != null) {
      return _isar.accountModels
          .filter()
          .userIdEqualTo(userId)
          .findAll();
    } else {
      return _isar.accountModels
          .filter()
          .userIdIsNull()
          .findAll();
    }
  }

  Future<void> putAccount(AccountModel account) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.accountModels.put(account);
      });
    } catch (e) {
      // ignore: avoid_print
      print('ISAR PUT ACCOUNT FAILED: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount(int id) async {
    await _isar.writeTxn(() async {
      await _isar.accountModels.delete(id);
    });
  }
}
