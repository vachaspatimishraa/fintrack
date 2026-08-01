import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/core/database/isar/collections/sync_queue_item.dart';
import 'package:fintrack/core/database/isar/collections/transaction_model.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';
import 'package:fintrack/core/database/isar/collections/budget_model.dart';
import 'package:fintrack/core/database/isar/collections/goal_model.dart';

void main() {
  group('Cloud Delete Sync & Reconciliation Unit Tests', () {
    test('SyncQueueItem constructs delete item correctly', () {
      final item = SyncQueueItem()
        ..entityType = 'transaction'
        ..entityUuid = 'tx-del-123'
        ..action = 'delete'
        ..payload = '{}'
        ..syncStatus = 'pending'
        ..retryCount = 0;

      expect(item.entityType, 'transaction');
      expect(item.entityUuid, 'tx-del-123');
      expect(item.action, 'delete');
      expect(item.syncStatus, 'pending');
    });

    test('TransactionModel handles soft deletion flag in JSON', () {
      final tx = TransactionModel()
        ..uuid = 'tx-999'
        ..title = 'Coffee'
        ..amount = 5.0
        ..isDeleted = true;

      final json = tx.toJson();
      expect(json['is_deleted'], true);

      final restored = TransactionModel.fromJson(json);
      expect(restored.isDeleted, true);
    });

    test('AccountModel handles soft deletion flag in JSON', () {
      final acc = AccountModel()
        ..uuid = 'acc-888'
        ..name = 'Old Wallet'
        ..isDeleted = true;

      final json = acc.toJson();
      expect(json['is_deleted'], true);

      final restored = AccountModel.fromJson(json);
      expect(restored.isDeleted, true);
    });

    test('BudgetModel handles soft deletion flag in JSON', () {
      final budget = BudgetModel()
        ..uuid = 'bgt-777'
        ..title = 'Summer Budget'
        ..isDeleted = true;

      final json = budget.toJson();
      expect(json['is_deleted'], true);

      final restored = BudgetModel.fromJson(json);
      expect(restored.isDeleted, true);
    });

    test('GoalModel handles soft deletion flag in JSON', () {
      final goal = GoalModel()
        ..uuid = 'goal-666'
        ..title = 'New Car'
        ..isDeleted = true;

      final json = goal.toJson();
      expect(json['is_deleted'], true);

      final restored = GoalModel.fromJson(json);
      expect(restored.isDeleted, true);
    });
  });
}
