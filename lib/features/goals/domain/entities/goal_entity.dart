class GoalEntity {
  final String uuid;
  final String ownerId;
  final String title;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime startDate;
  final DateTime deadline;
  final String status;
  final int priority;
  final String category;
  final String? color;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final String syncStatus;
  final int version;

  const GoalEntity({
    required this.uuid,
    required this.ownerId,
    required this.title,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    required this.startDate,
    required this.deadline,
    required this.status,
    required this.priority,
    required this.category,
    this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.syncStatus = 'synced',
    this.version = 1,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount) : 0;
  bool get isCompleted => currentAmount >= targetAmount;

  GoalEntity copyWith({
    String? uuid,
    String? ownerId,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? startDate,
    DateTime? deadline,
    String? status,
    int? priority,
    String? category,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    String? syncStatus,
    int? version,
  }) {
    return GoalEntity(
      uuid: uuid ?? this.uuid,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      version: version ?? this.version,
    );
  }
}
