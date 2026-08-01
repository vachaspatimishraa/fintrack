import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/isar/collections/account_model.dart';
import '../../../home/providers/home_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/providers/transaction_provider.dart';
import '../../providers/account_provider.dart';

class AccountController {
  final Ref _ref;

  AccountController(this._ref);

  Future<void> saveAccount({
    required AccountModel account,
    required String name,
    required String type,
    required double balance,
    required String icon,
    required int colorValue,
    String? notes,
    String? openingBalanceTitle,
    String? openingBalanceDesc,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Account name cannot be empty.');
    }
    if (trimmedName.length > 40) {
      throw ArgumentError('Account name cannot exceed 40 characters.');
    }

    final repository = _ref.read(accountRepositoryProvider);
    final activeAccounts = await repository.getAccounts();
    final isFirst = activeAccounts.isEmpty;
    final isNew = account.uuid.isEmpty;

    account.name = trimmedName;
    account.type = type;
    account.balance = balance;
    account.icon = icon;
    account.colorValue = colorValue;
    account.notes = notes;

    await repository.saveAccount(account);

    // If new account and balance > 0, create opening balance transaction
    if (isNew && balance > 0) {
      final transactionRepo = _ref.read(transactionRepositoryProvider);
      final openingTransaction = TransactionEntity(
        accountId: account.uuid,
        type: 'income',
        category: 'Opening Balance',
        categoryId: 'Opening Balance',
        amount: balance,
        title: openingBalanceTitle ?? 'Opening Balance',
        description: openingBalanceDesc ?? 'Initial balance for ${account.name}',
        date: DateTime.now(),
        isSystem: true,
      );
      await transactionRepo.saveTransaction(openingTransaction);
    }

    if (isNew) {
      // Set it as current account and last opened account
      await _ref.read(currentAccountProvider.notifier).selectAccount(account.uuid);
    }
  }

  Future<void> renameAccount(String uuid, String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Account name cannot be empty.');
    }
    if (trimmedName.length > 40) {
      throw ArgumentError('Account name cannot exceed 40 characters.');
    }

    final repository = _ref.read(accountRepositoryProvider);
    final account = await repository.getAccountByUuid(uuid);
    if (account != null) {
      account.name = trimmedName;
      await repository.saveAccount(account);
    }
  }

  Future<void> deleteAccount(String uuid) async {
    final repository = _ref.read(accountRepositoryProvider);
    
    // Soft delete
    await repository.deleteAccount(uuid);

    // If deleted account was the current selected one, switch to another active one
    final currentUuid = _ref.read(currentAccountProvider);
    if (currentUuid == uuid) {
      final active = await repository.getAccounts();
      if (active.isNotEmpty) {
        await _ref.read(currentAccountProvider.notifier).selectAccount(active.first.uuid);
      } else {
        await _ref.read(currentAccountProvider.notifier).selectAccount(null);
      }
    }

    _ref.invalidate(accountsStreamProvider);
    _ref.invalidate(allAccountsStreamProvider);
    _ref.invalidate(everythingAccountsStreamProvider);
    _ref.invalidate(currentAccountModelProvider);
    _ref.invalidate(totalBalanceProvider);
    _ref.invalidate(homeStateProvider);
    await _ref.read(homeStateProvider.notifier).refreshDashboard();
  }

  Future<void> archiveAccount(String uuid, bool archive) async {
    final repository = _ref.read(accountRepositoryProvider);
    await repository.archiveAccount(uuid, archive);

    // If archiving the current selected account, switch to another active one
    if (archive) {
      final currentUuid = _ref.read(currentAccountProvider);
      if (currentUuid == uuid) {
        final active = await repository.getAccounts();
        if (active.isNotEmpty) {
          await _ref.read(currentAccountProvider.notifier).selectAccount(active.first.uuid);
        } else {
          await _ref.read(currentAccountProvider.notifier).selectAccount(null);
        }
      }
    }
  }

  Future<void> selectAccount(String uuid) async {
    await _ref.read(currentAccountProvider.notifier).selectAccount(uuid);
  }

  Future<void> restoreAccount(String uuid) async {
    final repository = _ref.read(accountRepositoryProvider);
    await repository.restoreAccount(uuid);
  }
}

final accountControllerProvider = Provider<AccountController>((ref) => AccountController(ref));
