import '../../../../core/database/isar/collections/account_model.dart';

abstract class AccountRepository {
  Stream<List<AccountModel>> watchAccounts();
  Stream<List<AccountModel>> watchAllAccounts();
  Stream<List<AccountModel>> watchEverything();
  Future<List<AccountModel>> getAccounts();
  Future<List<AccountModel>> getAllActiveAccounts();
  Future<List<AccountModel>> getEverything();
  Future<AccountModel?> getAccountByUuid(String uuid);
  Future<void> saveAccount(AccountModel account);
  Future<void> deleteAccount(String uuid);
  Future<void> archiveAccount(String uuid, bool archive);
  Future<void> restoreAccount(String uuid);
  Future<void> syncAccounts();
}
