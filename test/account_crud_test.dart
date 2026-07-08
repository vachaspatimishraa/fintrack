import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';

void main() {
  group('AccountModel Test', () {
    test('fromJson and toJson maps correctly', () {
      final now = DateTime.now();
      final model = AccountModel()
        ..uuid = 'test_uuid_999'
        ..name = 'Savings Wallet'
        ..type = 'Savings'
        ..balance = 500.0
        ..icon = 'savings'
        ..colorValue = 123456
        ..createdAt = now
        ..updatedAt = now
        ..userId = 'user_id_xyz'
        ..isArchived = true
        ..isDeleted = false
        ..notes = 'Test note';

      final json = model.toJson();
      expect(json['id'], 'test_uuid_999');
      expect(json['name'], 'Savings Wallet');
      expect(json['balance'], 500.0);
      expect(json['is_archived'], true);
      expect(json['is_deleted'], false);
      expect(json['notes'], 'Test note');

      final parsed = AccountModel.fromJson(json);
      expect(parsed.uuid, 'test_uuid_999');
      expect(parsed.name, 'Savings Wallet');
      expect(parsed.balance, 500.0);
      expect(parsed.isArchived, true);
      expect(parsed.isDeleted, false);
      expect(parsed.notes, 'Test note');
    });
  });
}
