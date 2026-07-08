import '../entities/goal_analytics_model.dart';
import '../repositories/goal_repository.dart';

class GoalAnalyticsService {
  final GoalRepository _repository;

  GoalAnalyticsService(this._repository);

  Future<GoalAnalyticsModel> analyze(String goalId) async {
    final contributions = await _repository.loadContributions(goalId);
    
    return GoalAnalyticsModel(
      goalId: goalId,
      monthlyProgress: [],
      averageMonthlyContribution: 0.0,
      highestContribution: 0.0,
      totalContributions: contributions.length,
      averageTimeBetweenContributions: Duration.zero,
    );
  }
}
