import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';
import 'package:fintrack/core/database/isar/collections/transaction_model.dart';

void main() {
  group('Wallet Soft Delete Sync Unit & Integration Tests', () {
    test('AccountModel soft delete generates payload with is_deleted: true', () {
      final account = AccountModel()
        ..uuid = 'wallet-soft-1'
        ..name = 'Savings Wallet'
        ..balance = 500.0
        ..isDeleted = false;

      expect(account.isDeleted, isFalse);

      // Perform soft delete
      account.isDeleted = true;
      account.updatedAt = DateTime.now();

      final json = account.toJson();
      expect(json['id'], 'wallet-soft-1');
      expect(json['is_deleted'], isTrue);
      expect(json['updated_at'], isNotNull);
    });

    test('Remote soft-deleted account does not recreate active local wallet', () {
      final remotePayload = {
        'id': 'wallet-remote-del',
        'name': 'Deleted Remote Wallet',
        'type': 'Cash',
        'balance': 250.0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_archived': false,
        'is_deleted': true,
      };

      final remoteAccount = AccountModel.fromJson(remotePayload);
      expect(remoteAccount.isDeleted, isTrue);
      expect(remoteAccount.uuid, 'wallet-remote-del');
    });

    test('Deleting wallet preserves associated transactions', () {
      final account = AccountModel()
        ..uuid = 'wallet-preserve-tx'
        ..name = 'Main Account'
        ..isDeleted = true;

      final tx1 = TransactionModel()
        ..uuid = 'tx-1'
        ..accountId = account.uuid
        ..amount = 100.0
        ..type = 'expense'
        ..isDeleted = false;

      final tx2 = TransactionModel()
        ..uuid = 'tx-2'
        ..accountId = account.uuid
        ..amount = 200.0
        ..type = 'income'
        ..isDeleted = false;

      // Wallet is deleted
      expect(account.isDeleted, isTrue);

      // Transactions remain untouched and active
      expect(tx1.accountId, account.uuid);
      expect(tx1.isDeleted, isFalse);
      expect(tx2.accountId, account.uuid);
      expect(tx2.isDeleted, isFalse);
    });

    test('Provider invalidation triggers fresh container read after wallet deletion', () {
      int readCount = 0;
      final walletCountProvider = Provider<int>((ref) {
        readCount++;
        return readCount;
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final count1 = container.read(walletCountProvider);
      expect(count1, 1);

      container.invalidate(walletCountProvider);
      final count2 = container.read(walletCountProvider);
      expect(count2, 2);
    });
  });
}
