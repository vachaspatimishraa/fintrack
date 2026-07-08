import '../entities/budget_alert_entity.dart';

/// Contract for managing financial alerts and threshold notifications.
abstract class BudgetAlertRepository {
  /// Stream of active alerts (not dismissed or resolved).
  Stream<List<BudgetAlertEntity>> watchActiveAlerts();

  /// Stream of all alerts for historical viewing.
  Stream<List<BudgetAlertEntity>> watchAlertHistory();

  /// Retrieves alerts associated with a specific budget.
  Future<List<BudgetAlertEntity>> getAlertsByBudgetId(String budgetId);

  /// Saves or updates an alert.
  Future<void> saveAlert(BudgetAlertEntity alert);

  /// Marks an alert as dismissed by the user.
  Future<void> dismissAlert(String uuid);

  /// Marks an alert as resolved (e.g. overspending corrected).
  Future<void> resolveAlert(String uuid);

  /// Permanently removes an alert record.
  Future<void> deleteAlert(String uuid);

  /// Retrieves high-severity alerts.
  Future<List<BudgetAlertEntity>> getCriticalAlerts();

  /// Retrieves warning-level alerts.
  Future<List<BudgetAlertEntity>> getWarningAlerts();
}
