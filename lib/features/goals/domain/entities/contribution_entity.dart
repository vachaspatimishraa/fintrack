class ContributionEntity {
  final String uuid;
  final String goalId;
  final double amount;
  final String? note;
  final String? transactionId;
  final DateTime createdAt;

  const ContributionEntity({
    required this.uuid,
    required this.goalId,
    required this.amount,
    this.note,
    this.transactionId,
    required this.createdAt,
  });

  ContributionEntity copyWith({
    String? uuid,
    String? goalId,
    double? amount,
    String? note,
    String? transactionId,
    DateTime? createdAt,
  }) {
    return ContributionEntity(
      uuid: uuid ?? this.uuid,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
