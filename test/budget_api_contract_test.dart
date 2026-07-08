import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/budget/domain/entities/budget_api_contract.dart';
import 'package:fintrack/features/budget/data/mappers/budget_mapper.dart';
import 'package:fintrack/features/budget/domain/entities/budget_entity.dart';

void main() {
  group('BudgetApiContract', () {
    test('Mapper should follow contract keys', () {
      final entity = BudgetEntity(
        uuid: 'uuid-1',
        ownerId: 'user-1',
        title: 'Test Budget',
        budgetType: 'overall',
        amount: 1000.0,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = BudgetMapper.toJson(entity);

      expect(json[BudgetApiContract.fId], entity.uuid);
      expect(json[BudgetApiContract.fOwnerId], entity.ownerId);
      expect(json[BudgetApiContract.fTitle], entity.title);
      expect(json[BudgetApiContract.fAmount], entity.amount);
    });
  });
}
