import '../../../../core/database/isar/collections/budget_recommendation_model.dart';
import '../../domain/entities/budget_recommendation_entity.dart';

class BudgetRecommendationMapper {
  static BudgetRecommendationEntity toEntity(BudgetRecommendationModel model) {
    return BudgetRecommendationEntity(
      uuid: model.uuid,
      userId: model.userId,
      type: model.type,
      title: model.title,
      message: model.message,
      reason: model.reason,
      expectedSavings: model.expectedSavings,
      confidence: model.confidence,
      accepted: model.accepted,
      dismissed: model.dismissed,
      applied: model.applied,
      createdAt: model.createdAt,
      appliedAt: model.appliedAt,
      dismissedAt: model.dismissedAt,
      severity: model.severity,
      budgetId: model.budgetId,
      categoryId: model.categoryId,
    );
  }

  static BudgetRecommendationModel toModel(BudgetRecommendationEntity entity) {
    return BudgetRecommendationModel()
      ..uuid = entity.uuid
      ..userId = entity.userId
      ..type = entity.type
      ..title = entity.title
      ..message = entity.message
      ..reason = entity.reason
      ..expectedSavings = entity.expectedSavings
      ..confidence = entity.confidence
      ..accepted = entity.accepted
      ..dismissed = entity.dismissed
      ..applied = entity.applied
      ..createdAt = entity.createdAt
      ..appliedAt = entity.appliedAt
      ..dismissedAt = entity.dismissedAt
      ..severity = entity.severity
      ..budgetId = entity.budgetId
      ..categoryId = entity.categoryId;
  }
}
