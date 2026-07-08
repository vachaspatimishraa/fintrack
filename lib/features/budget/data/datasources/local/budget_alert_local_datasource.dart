import 'package:isar/isar.dart';
import '../../../../../core/database/isar/collections/budget_model.dart';

class BudgetAlertLocalDatasource {
  final Isar _isar;

  BudgetAlertLocalDatasource(this._isar);

  Stream<List<BudgetAlertModel>> watchActiveAlerts() {
    return _isar.budgetAlertModels
        .filter()
        .dismissedEqualTo(false)
        .resolvedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<BudgetAlertModel>> watchAlertHistory() {
    return _isar.budgetAlertModels
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<List<BudgetAlertModel>> getAlertsByBudgetId(String budgetId) {
    return _isar.budgetAlertModels
        .filter()
        .budgetIdEqualTo(budgetId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<void> putAlert(BudgetAlertModel alert) async {
    await _isar.writeTxn(() async {
      await _isar.budgetAlertModels.put(alert);
    });
  }

  Future<BudgetAlertModel?> getAlertByUuid(String uuid) {
    return _isar.budgetAlertModels.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<void> deleteAlert(String uuid) async {
    await _isar.writeTxn(() async {
      await _isar.budgetAlertModels.filter().uuidEqualTo(uuid).deleteFirst();
    });
  }

  Future<List<BudgetAlertModel>> getAlertsBySeverity(String severity) {
    return _isar.budgetAlertModels
        .filter()
        .severityEqualTo(severity)
        .dismissedEqualTo(false)
        .resolvedEqualTo(false)
        .findAll();
  }
}
