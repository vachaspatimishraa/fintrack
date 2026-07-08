class BudgetHistoryEntity {
  final String uuid;
  final String budgetId;
  final String action;
  final String oldValue;
  final String newValue;
  final DateTime timestamp;
  final String deviceId;
  final String syncStatus;

  BudgetHistoryEntity({
    required this.uuid,
    required this.budgetId,
    required this.action,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
    required this.deviceId,
    this.syncStatus = 'synced',
  });
}
