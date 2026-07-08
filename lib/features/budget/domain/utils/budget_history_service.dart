import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/isar/collections/budget_model.dart';

class BudgetHistoryService {
  final Isar _isar;

  BudgetHistoryService(this._isar);

  Future<void> recordAction({
    required String budgetUuid,
    required String action,
    String oldValue = '',
    String newValue = '',
  }) async {
    final history = BudgetHistoryModel()
      ..uuid = const Uuid().v4()
      ..budgetId = budgetUuid
      ..action = action
      ..oldValue = oldValue
      ..newValue = newValue
      ..timestamp = DateTime.now()
      ..deviceId = 'current-device' // Ideally get real device ID
      ..syncStatus = 'pending';

    await _isar.writeTxn(() async {
      await _isar.budgetHistoryModels.put(history);
    });
  }
}
