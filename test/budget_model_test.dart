import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/core/database/isar/collections/budget_model.dart';

void main() {
  group('BudgetModel', () {
    test('toJson and fromJson should be symmetrical', () {
      final model = BudgetModel()
        ..uuid = '123'
        ..ownerId = 'user1'
        ..title = 'Groceries'
        ..budgetType = 'category'
        ..amount = 500.0
        ..currency = 'INR'
        ..startDate = DateTime(2026, 7, 1)
        ..endDate = DateTime(2026, 7, 31)
        ..spentAmount = 100.0
        ..remainingAmount = 400.0
        ..progress = 20.0
        ..status = 'active'
        ..alertThreshold = 80.0
        ..rolloverEnabled = false
        ..carryForward = 0.0
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDeleted = false
        ..syncStatus = 'synced'
        ..version = 1;

      final json = model.toJson();
      final fromJson = BudgetModel.fromJson(json);

      expect(fromJson.uuid, model.uuid);
      expect(fromJson.amount, model.amount);
      expect(fromJson.status, model.status);
    });
  });
}
