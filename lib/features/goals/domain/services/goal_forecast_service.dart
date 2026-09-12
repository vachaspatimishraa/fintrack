import 'package:fintrack/features/goals/domain/entities/goal_forecast_model.dart';
import 'package:fintrack/features/goals/domain/repositories/goal_repository.dart';

class GoalForecastService {
  final GoalRepository _repository;

  GoalForecastService(this._repository);

  Future<GoalForecastModel> generateForecast(String goalId) async {
    // Basic linear forecast implementation
    final goal = await _repository.loadGoal(goalId);
    if (goal == null) throw Exception('Goal not found');

    final remainingAmount = goal.targetAmount - goal.currentAmount;
    
    return GoalForecastModel(
      goalId: goalId,
      expectedCompletionDate: goal.deadline,
      projectedSavingsRate: 100.0, // Placeholder
      requiredSavingsRate: remainingAmount > 0 ? remainingAmount / 12 : 0.0,
      feasibilityStatus: 'On track',
    );
  }
}
