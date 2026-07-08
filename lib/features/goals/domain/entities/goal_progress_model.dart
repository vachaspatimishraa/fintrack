class GoalProgressModel {
  final String goalId;
  final double percentage;
  final double currentAmount;
  final double targetAmount;
  final double remainingAmount;
  final int completedMilestones;
  final int totalMilestones;

  const GoalProgressModel({
    required this.goalId,
    required this.percentage,
    required this.currentAmount,
    required this.targetAmount,
    required this.remainingAmount,
    required this.completedMilestones,
    required this.totalMilestones,
  });
}
