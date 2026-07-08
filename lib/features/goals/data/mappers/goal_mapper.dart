import '../../../../core/database/isar/collections/goal_model.dart';
import '../../domain/entities/goal_entity.dart';

class GoalMapper {
  static GoalEntity toEntity(GoalModel model) {
    return GoalEntity(
      uuid: model.uuid,
      ownerId: model.ownerId,
      title: model.title,
      description: model.description,
      targetAmount: model.targetAmount,
      currentAmount: model.currentAmount,
      currency: model.currency,
      startDate: model.startDate,
      deadline: model.deadline,
      status: model.status,
      priority: model.priority,
      category: model.category,
      color: model.color,
      icon: model.icon,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isDeleted: model.isDeleted,
      syncStatus: model.syncStatus,
      version: model.version,
    );
  }

  static GoalModel toModel(GoalEntity entity) {
    return GoalModel()
      ..uuid = entity.uuid
      ..ownerId = entity.ownerId
      ..title = entity.title
      ..description = entity.description
      ..targetAmount = entity.targetAmount
      ..currentAmount = entity.currentAmount
      ..currency = entity.currency
      ..startDate = entity.startDate
      ..deadline = entity.deadline
      ..status = entity.status
      ..priority = entity.priority
      ..category = entity.category
      ..color = entity.color
      ..icon = entity.icon
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..isDeleted = entity.isDeleted
      ..syncStatus = entity.syncStatus
      ..version = entity.version;
  }
}
