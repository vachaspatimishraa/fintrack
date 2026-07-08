import '../../domain/entities/budget_alert_entity.dart';
import '../../domain/repositories/budget_alert_repository.dart';
import '../datasources/local/budget_alert_local_datasource.dart';
import '../mappers/budget_alert_mapper.dart';

class BudgetAlertRepositoryImpl implements BudgetAlertRepository {
  final BudgetAlertLocalDatasource _localDatasource;

  BudgetAlertRepositoryImpl(this._localDatasource);

  @override
  Stream<List<BudgetAlertEntity>> watchActiveAlerts() {
    return _localDatasource.watchActiveAlerts().map(
          (models) => models.map((m) => BudgetAlertMapper.toEntity(m)).toList(),
        );
  }

  @override
  Stream<List<BudgetAlertEntity>> watchAlertHistory() {
    return _localDatasource.watchAlertHistory().map(
          (models) => models.map((m) => BudgetAlertMapper.toEntity(m)).toList(),
        );
  }

  @override
  Future<List<BudgetAlertEntity>> getAlertsByBudgetId(String budgetId) async {
    final models = await _localDatasource.getAlertsByBudgetId(budgetId);
    return models.map((m) => BudgetAlertMapper.toEntity(m)).toList();
  }

  @override
  Future<void> saveAlert(BudgetAlertEntity alert) async {
    final model = BudgetAlertMapper.toModel(alert);
    await _localDatasource.putAlert(model);
  }

  @override
  Future<void> dismissAlert(String uuid) async {
    final model = await _localDatasource.getAlertByUuid(uuid);
    if (model != null) {
      model.dismissed = true;
      model.dismissedAt = DateTime.now();
      await _localDatasource.putAlert(model);
    }
  }

  @override
  Future<void> resolveAlert(String uuid) async {
    final model = await _localDatasource.getAlertByUuid(uuid);
    if (model != null) {
      model.resolved = true;
      model.resolvedAt = DateTime.now();
      await _localDatasource.putAlert(model);
    }
  }

  @override
  Future<void> deleteAlert(String uuid) async {
    await _localDatasource.deleteAlert(uuid);
  }

  @override
  Future<List<BudgetAlertEntity>> getCriticalAlerts() async {
    final models = await _localDatasource.getAlertsBySeverity('critical');
    return models.map((m) => BudgetAlertMapper.toEntity(m)).toList();
  }

  @override
  Future<List<BudgetAlertEntity>> getWarningAlerts() async {
    final models = await _localDatasource.getAlertsBySeverity('medium'); // or 'high'
    return models.map((m) => BudgetAlertMapper.toEntity(m)).toList();
  }
}
