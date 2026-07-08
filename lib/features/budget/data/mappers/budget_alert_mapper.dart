import '../../../../core/database/isar/collections/budget_model.dart';
import '../../domain/entities/budget_alert_entity.dart';

class BudgetAlertMapper {
  static BudgetAlertEntity toEntity(BudgetAlertModel model) {
    return BudgetAlertEntity(
      uuid: model.uuid,
      budgetId: model.budgetId,
      alertType: model.alertType,
      severity: model.severity,
      title: model.title,
      message: model.message,
      threshold: model.threshold,
      triggered: model.triggered,
      triggeredAt: model.triggeredAt,
      dismissed: model.dismissed,
      dismissedAt: model.dismissedAt,
      resolved: model.resolved,
      resolvedAt: model.resolvedAt,
      actionTaken: model.actionTaken,
      createdAt: model.createdAt,
      syncStatus: model.syncStatus,
    );
  }

  static BudgetAlertModel toModel(BudgetAlertEntity entity) {
    return BudgetAlertModel()
      ..uuid = entity.uuid
      ..budgetId = entity.budgetId
      ..alertType = entity.alertType
      ..severity = entity.severity
      ..title = entity.title
      ..message = entity.message
      ..threshold = entity.threshold
      ..triggered = entity.triggered
      ..triggeredAt = entity.triggeredAt
      ..dismissed = entity.dismissed
      ..dismissedAt = entity.dismissedAt
      ..resolved = entity.resolved
      ..resolvedAt = entity.resolvedAt
      ..actionTaken = entity.actionTaken
      ..createdAt = entity.createdAt
      ..syncStatus = entity.syncStatus;
  }
}
