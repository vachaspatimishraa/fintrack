import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';
import 'package:fintrack/features/accounts/data/mappers/account_mapper.dart';
import 'package:fintrack/features/accounts/data/adapters/account_sync_adapter.dart';

void main() {
  group('AccountMapper & AccountSyncAdapter Tests', () {
    test('AccountMapper converts json back and forth correctly', () {
      final now = DateTime.now();
      final original = AccountModel()
        ..uuid = 'map-test-uuid'
        ..name = 'ICICI Bank'
        ..type = 'bank'
        ..balance = 120000.0
        ..icon = 'bank'
        ..colorValue = 456789
        ..createdAt = now
        ..updatedAt = now
        ..isArchived = true
        ..isDeleted = false
        ..notes = 'Salary account';

      final jsonMap = AccountMapper.toJson(original);
      expect(jsonMap['id'], 'map-test-uuid');
      expect(jsonMap['name'], 'ICICI Bank');
      expect(jsonMap['balance'], 120000.0);
      expect(jsonMap['is_archived'], true);

      final decoded = AccountMapper.fromJson(jsonMap);
      expect(decoded.uuid, original.uuid);
      expect(decoded.name, original.name);
      expect(decoded.balance, original.balance);
      expect(decoded.isArchived, original.isArchived);
    });

    test('AccountSyncAdapter adds user_id payload correctly', () {
      final now = DateTime.now();
      final original = AccountModel()
        ..uuid = 'sync-test-uuid'
        ..name = 'My cash'
        ..type = 'cash'
        ..balance = 400.0
        ..icon = 'wallet'
        ..colorValue = 112233
        ..createdAt = now
        ..updatedAt = now;

      final payload = AccountSyncAdapter.toRemotePayload(original, 'user_999');
      expect(payload['user_id'], 'user_999');
      expect(payload['id'], 'sync-test-uuid');

      final reconstructed = AccountSyncAdapter.fromRemotePayload(payload);
      expect(reconstructed.uuid, 'sync-test-uuid');
      expect(reconstructed.isSynced, isTrue);
    });
  });
}
