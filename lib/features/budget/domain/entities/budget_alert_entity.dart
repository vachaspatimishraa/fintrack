class BudgetAlertEntity {
  final String uuid;
  final String budgetId;
  final String alertType;
  final String severity;
  final String title;
  final String message;
  final double threshold;
  final bool triggered;
  final DateTime? triggeredAt;
  final bool dismissed;
  final DateTime? dismissedAt;
  final bool resolved;
  final DateTime? resolvedAt;
  final String? actionTaken;
  final DateTime createdAt;
  final String syncStatus;

  BudgetAlertEntity({
    required this.uuid,
    required this.budgetId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.message,
    required this.threshold,
    this.triggered = false,
    this.triggeredAt,
    this.dismissed = false,
    this.dismissedAt,
    this.resolved = false,
    this.resolvedAt,
    this.actionTaken,
    required this.createdAt,
    this.syncStatus = 'synced',
  });

  BudgetAlertEntity copyWith({
    String? uuid,
    String? budgetId,
    String? alertType,
    String? severity,
    String? title,
    String? message,
    double? threshold,
    bool? triggered,
    DateTime? triggeredAt,
    bool? dismissed,
    DateTime? dismissedAt,
    bool? resolved,
    DateTime? resolvedAt,
    String? actionTaken,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return BudgetAlertEntity(
      uuid: uuid ?? this.uuid,
      budgetId: budgetId ?? this.budgetId,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      threshold: threshold ?? this.threshold,
      triggered: triggered ?? this.triggered,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      dismissed: dismissed ?? this.dismissed,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      resolved: resolved ?? this.resolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      actionTaken: actionTaken ?? this.actionTaken,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
