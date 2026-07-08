class GoalForecastModel {
  final String goalId;
  final DateTime expectedCompletionDate;
  final double projectedSavingsRate;
  final double requiredSavingsRate;
  final String feasibilityStatus; // On track, Behind, Critical

  const GoalForecastModel({
    required this.goalId,
    required this.expectedCompletionDate,
    required this.projectedSavingsRate,
    required this.requiredSavingsRate,
    required this.feasibilityStatus,
  });
}
