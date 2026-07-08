import '../../../../core/database/isar/collections/budget_model.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/budget_api_contract.dart';

/// Contract-compliant mapper for serialization and deserialization.
class BudgetMapper {
  static BudgetEntity toEntity(BudgetModel model) {
    return BudgetEntity(
      uuid: model.uuid,
      ownerId: model.ownerId,
      title: model.title,
      description: model.description,
      budgetType: model.budgetType,
      amount: model.amount,
      currency: model.currency,
      startDate: model.startDate,
      endDate: model.endDate,
      categoryId: model.categoryId,
      accountId: model.accountId,
      spentAmount: model.spentAmount,
      remainingAmount: model.remainingAmount,
      progress: model.progress,
      status: model.status,
      alertThreshold: model.alertThreshold,
      rolloverEnabled: model.rolloverEnabled,
      carryForward: model.carryForward,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
      isDeleted: model.isDeleted,
      syncStatus: model.syncStatus,
      version: model.version,
    );
  }

  static BudgetModel toModel(BudgetEntity entity) {
    return BudgetModel()
      ..uuid = entity.uuid
      ..ownerId = entity.ownerId
      ..title = entity.title
      ..description = entity.description
      ..budgetType = entity.budgetType
      ..amount = entity.amount
      ..currency = entity.currency
      ..startDate = entity.startDate
      ..endDate = entity.endDate
      ..categoryId = entity.categoryId
      ..accountId = entity.accountId
      ..spentAmount = entity.spentAmount
      ..remainingAmount = entity.remainingAmount
      ..progress = entity.progress
      ..status = entity.status
      ..alertThreshold = entity.alertThreshold
      ..rolloverEnabled = entity.rolloverEnabled
      ..carryForward = entity.carryForward
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..deletedAt = entity.deletedAt
      ..isDeleted = entity.isDeleted
      ..syncStatus = entity.syncStatus
      ..version = entity.version;
  }

  static BudgetEntity fromJson(Map<String, dynamic> json) {
    return BudgetEntity(
      uuid: json[BudgetApiContract.fId] as String? ?? '',
      ownerId: json[BudgetApiContract.fOwnerId] as String? ?? '',
      title: json[BudgetApiContract.fTitle] as String? ?? '',
      description: json['description'] as String?,
      budgetType: json['budget_type'] as String? ?? BudgetApiContract.statusActive,
      amount: (json[BudgetApiContract.fAmount] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date'] as String) 
          : DateTime.now(),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'] as String) 
          : DateTime.now(),
      categoryId: json['category_id'] as String?,
      accountId: json['account_id'] as String?,
      spentAmount: (json[BudgetApiContract.fSpentAmount] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json[BudgetApiContract.fRemainingAmount] as num?)?.toDouble() ?? 0.0,
      progress: (json[BudgetApiContract.fProgress] as num?)?.toDouble() ?? 0.0,
      status: json[BudgetApiContract.fStatus] as String? ?? BudgetApiContract.statusActive,
      alertThreshold: (json['alert_threshold'] as num?)?.toDouble() ?? 80.0,
      rolloverEnabled: json['rollover_enabled'] as bool? ?? false,
      carryForward: (json['carry_forward'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      updatedAt: json[BudgetApiContract.fUpdatedAt] != null 
          ? DateTime.parse(json[BudgetApiContract.fUpdatedAt] as String) 
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
      syncStatus: json['sync_status'] as String? ?? 'synced',
      version: json[BudgetApiContract.fVersion] as int? ?? 1,
    );
  }

  static Map<String, dynamic> toJson(BudgetEntity entity) {
    return {
      BudgetApiContract.fId: entity.uuid,
      BudgetApiContract.fOwnerId: entity.ownerId,
      BudgetApiContract.fTitle: entity.title,
      'description': entity.description,
      'budget_type': entity.budgetType,
      BudgetApiContract.fAmount: entity.amount,
      'currency': entity.currency,
      'start_date': entity.startDate.toIso8601String(),
      'end_date': entity.endDate.toIso8601String(),
      'category_id': entity.categoryId,
      'account_id': entity.accountId,
      BudgetApiContract.fSpentAmount: entity.spentAmount,
      BudgetApiContract.fRemainingAmount: entity.remainingAmount,
      BudgetApiContract.fProgress: entity.progress,
      BudgetApiContract.fStatus: entity.status,
      'alert_threshold': entity.alertThreshold,
      'rollover_enabled': entity.rolloverEnabled,
      'carry_forward': entity.carryForward,
      'created_at': entity.createdAt.toIso8601String(),
      BudgetApiContract.fUpdatedAt: entity.updatedAt.toIso8601String(),
      'deleted_at': entity.deletedAt?.toIso8601String(),
      'is_deleted': entity.isDeleted,
      'sync_status': entity.syncStatus,
      BudgetApiContract.fVersion: entity.version,
    };
  }
}
