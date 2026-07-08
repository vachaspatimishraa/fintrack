class GoalAnalyticsModel {
  final String goalId;
  final List<double> monthlyProgress;
  final double averageMonthlyContribution;
  final double highestContribution;
  final int totalContributions;
  final Duration averageTimeBetweenContributions;

  const GoalAnalyticsModel({
    required this.goalId,
    required this.monthlyProgress,
    required this.averageMonthlyContribution,
    required this.highestContribution,
    required this.totalContributions,
    required this.averageTimeBetweenContributions,
  });
}
