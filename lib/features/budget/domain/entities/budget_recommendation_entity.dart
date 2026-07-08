class BudgetRecommendationEntity {
  final String uuid;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String reason;
  final double expectedSavings;
  final double confidence;
  final bool accepted;
  final bool dismissed;
  final bool applied;
  final DateTime createdAt;
  final DateTime? appliedAt;
  final DateTime? dismissedAt;
  final String severity;
  final String? budgetId;
  final String? categoryId;

  BudgetRecommendationEntity({
    required this.uuid,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.reason,
    this.expectedSavings = 0.0,
    this.confidence = 0.0,
    this.accepted = false,
    this.dismissed = false,
    this.applied = false,
    required this.createdAt,
    this.appliedAt,
    this.dismissedAt,
    required this.severity,
    this.budgetId,
    this.categoryId,
  });

  BudgetRecommendationEntity copyWith({
    String? uuid,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? reason,
    double? expectedSavings,
    double? confidence,
    bool? accepted,
    bool? dismissed,
    bool? applied,
    DateTime? createdAt,
    DateTime? appliedAt,
    DateTime? dismissedAt,
    String? severity,
    String? budgetId,
    String? categoryId,
  }) {
    return BudgetRecommendationEntity(
      uuid: uuid ?? this.uuid,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      reason: reason ?? this.reason,
      expectedSavings: expectedSavings ?? this.expectedSavings,
      confidence: confidence ?? this.confidence,
      accepted: accepted ?? this.accepted,
      dismissed: dismissed ?? this.dismissed,
      applied: applied ?? this.applied,
      createdAt: createdAt ?? this.createdAt,
      appliedAt: appliedAt ?? this.appliedAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      severity: severity ?? this.severity,
      budgetId: budgetId ?? this.budgetId,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
