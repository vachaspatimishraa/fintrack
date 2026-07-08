import 'package:isar/isar.dart';

part 'budget_model.g.dart';

/// Isar collection representing a user's spending limit.
/// 
/// Stores both raw budget data and cached calculation results for performance.
@collection
class BudgetModel {
  Id id = Isar.autoIncrement;

  /// Globally unique identifier.
  @Index(unique: true, replace: true)
  String uuid = '';

  /// ID of the user who owns this budget.
  @Index(composite: [CompositeIndex('status'), CompositeIndex('updatedAt')])
  String ownerId = '';

  /// Display name of the budget.
  String title = '';

  /// Optional detailed notes.
  String? description;
  
  /// Type of budget (e.g., 'overall' or 'category').
  String budgetType = 'overall';

  /// Maximum amount allowed to be spent.
  double amount = 0.0;

  /// ISO currency code.
  String currency = 'USD';
  
  /// Start date of the budgeting period.
  @Index()
  DateTime startDate = DateTime.now();
  
  /// End date of the budgeting period.
  @Index()
  DateTime endDate = DateTime.now();
  
  /// Associated category ID for category-specific budgets.
  @Index(composite: [CompositeIndex('status')])
  String? categoryId;
  
  /// Associated account ID for account-specific budgets.
  String? accountId;
  
  // Calculated/Cached values
  
  /// Total amount already spent in this budget.
  double spentAmount = 0.0;

  /// Remaining funds in the budget.
  double remainingAmount = 0.0;

  /// Percentage of the budget utilized (0-100+).
  double progress = 0.0;
  
  /// Current status (e.g., 'active', 'warning', 'exceeded').
  @Index()
  String status = 'active';

  /// Threshold percentage that triggers a warning alert.
  double alertThreshold = 80.0;
  
  /// Whether to carry forward remaining balance to the next period.
  bool rolloverEnabled = false;

  /// Amount carried forward from the previous period.
  double carryForward = 0.0;
  
  /// Timestamp when the budget was created.
  DateTime createdAt = DateTime.now();
  
  /// Timestamp of the last modification.
  @Index()
  DateTime updatedAt = DateTime.now();
  
  /// Timestamp when the budget was soft-deleted.
  DateTime? deletedAt;
  
  /// Flag indicating if the budget is marked for deletion.
  @Index()
  bool isDeleted = false;
  
  /// Cloud synchronization status.
  String syncStatus = 'pending';

  /// Version for conflict resolution.
  int version = 1;

  /// Converts the model to a JSON map for remote API calls.
  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'user_id': ownerId,
      'title': title,
      'description': description,
      'budget_type': budgetType,
      'amount': amount,
      'currency': currency,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'category_id': categoryId,
      'account_id': accountId,
      'spent_amount': spentAmount,
      'remaining_amount': remainingAmount,
      'progress': progress,
      'status': status,
      'alert_threshold': alertThreshold,
      'rollover_enabled': rolloverEnabled,
      'carry_forward': carryForward,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'sync_status': syncStatus,
      'version': version,
    };
  }

  static BudgetModel fromJson(Map<String, dynamic> json) {
    return BudgetModel()
      ..uuid = json['id'] as String? ?? ''
      ..ownerId = (json['user_id'] ?? json['owner_id']) as String? ?? ''
      ..title = json['title'] as String? ?? ''
      ..description = json['description'] as String?
      ..budgetType = json['budget_type'] as String? ?? 'overall'
      ..amount = (json['amount'] as num?)?.toDouble() ?? 0.0
      ..currency = json['currency'] as String? ?? 'INR'
      ..startDate = DateTime.parse(json['start_date'] as String)
      ..endDate = DateTime.parse(json['end_date'] as String)
      ..categoryId = json['category_id'] as String?
      ..accountId = json['account_id'] as String?
      ..spentAmount = (json['spent_amount'] as num?)?.toDouble() ?? 0.0
      ..remainingAmount = (json['remaining_amount'] as num?)?.toDouble() ?? 0.0
      ..progress = (json['progress'] as num?)?.toDouble() ?? 0.0
      ..status = json['status'] as String? ?? 'active'
      ..alertThreshold = (json['alert_threshold'] as num?)?.toDouble() ?? 80.0
      ..rolloverEnabled = json['rollover_enabled'] as bool? ?? false
      ..carryForward = (json['carry_forward'] as num?)?.toDouble() ?? 0.0
      ..createdAt = DateTime.parse(json['created_at'] as String)
      ..updatedAt = DateTime.parse(json['updated_at'] as String)
      ..deletedAt = json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null
      ..isDeleted = json['is_deleted'] as bool? ?? false
      ..syncStatus = json['sync_status'] as String? ?? 'synced'
      ..version = json['version'] as int? ?? 1;
  }
}

@collection
class BudgetCategoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  @Index()
  String budgetId = '';

  @Index()
  String categoryId = '';

  double allocatedAmount = 0.0;
  double spentAmount = 0.0;
  double remainingAmount = 0.0;
  double progress = 0.0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

@collection
class BudgetHistoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  @Index()
  String budgetId = '';

  String action = '';
  String oldValue = '';
  String newValue = '';
  
  @Index()
  DateTime timestamp = DateTime.now();
  
  String deviceId = '';
  String syncStatus = 'pending';
}

@collection
class BudgetAlertModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  @Index()
  String budgetId = '';

  String alertType = 'warning'; // warning, critical, exceeded, daily_limit, etc.
  
  @Index()
  String severity = 'medium'; // informational, low, medium, high, critical
  
  String title = '';
  String message = '';
  
  double threshold = 0.0;
  
  @Index()
  bool triggered = false;
  DateTime? triggeredAt;
  
  @Index()
  bool dismissed = false;
  DateTime? dismissedAt;
  
  @Index()
  bool resolved = false;
  DateTime? resolvedAt;
  
  String? actionTaken;
  
  @Index()
  DateTime createdAt = DateTime.now();
  String syncStatus = 'pending';
}
