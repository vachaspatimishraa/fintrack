class MilestoneEntity {
  final String uuid;
  final String goalId;
  final String title;
  final double targetAmount;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MilestoneEntity({
    required this.uuid,
    required this.goalId,
    required this.title,
    required this.targetAmount,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  MilestoneEntity copyWith({
    String? uuid,
    String? goalId,
    String? title,
    double? targetAmount,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MilestoneEntity(
      uuid: uuid ?? this.uuid,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
