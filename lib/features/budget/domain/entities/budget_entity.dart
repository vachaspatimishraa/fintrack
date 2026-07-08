class BudgetEntity {
  final String uuid;
  final String ownerId;
  final String title;
  final String? description;
  final String budgetType;
  final double amount;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final String? categoryId;
  final String? accountId;
  final double spentAmount;
  final double remainingAmount;
  final double progress;
  final String status;
  final double alertThreshold;
  final bool rolloverEnabled;
  final double carryForward;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;
  final String syncStatus;
  final int version;

  BudgetEntity({
    required this.uuid,
    required this.ownerId,
    required this.title,
    this.description,
    required this.budgetType,
    required this.amount,
    this.currency = 'INR',
    required this.startDate,
    required this.endDate,
    this.categoryId,
    this.accountId,
    this.spentAmount = 0.0,
    this.remainingAmount = 0.0,
    this.progress = 0.0,
    this.status = 'active',
    this.alertThreshold = 80.0,
    this.rolloverEnabled = false,
    this.carryForward = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isDeleted = false,
    this.syncStatus = 'synced',
    this.version = 1,
  });

  BudgetEntity copyWith({
    String? uuid,
    String? ownerId,
    String? title,
    String? description,
    String? budgetType,
    double? amount,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? accountId,
    double? spentAmount,
    double? remainingAmount,
    double? progress,
    String? status,
    double? alertThreshold,
    bool? rolloverEnabled,
    double? carryForward,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isDeleted,
    String? syncStatus,
    int? version,
  }) {
    return BudgetEntity(
      uuid: uuid ?? this.uuid,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      budgetType: budgetType ?? this.budgetType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      spentAmount: spentAmount ?? this.spentAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
      carryForward: carryForward ?? this.carryForward,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      version: version ?? this.version,
    );
  }
}
