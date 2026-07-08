import '../entities/goal_progress_model.dart';
import '../repositories/goal_repository.dart';

class GoalProgressService {
  final GoalRepository _repository;

  GoalProgressService(this._repository);

  Future<GoalProgressModel> calculate(String goalId) async {
    final goal = await _repository.loadGoal(goalId);
    if (goal == null) throw Exception('Goal not found');

    final milestones = await _repository.loadMilestones(goalId);
    final completedMilestones = milestones.where((m) => m.isCompleted).length;

    return GoalProgressModel(
      goalId: goalId,
      percentage: goal.progress,
      currentAmount: goal.currentAmount,
      targetAmount: goal.targetAmount,
      remainingAmount: goal.targetAmount - goal.currentAmount,
      completedMilestones: completedMilestones,
      totalMilestones: milestones.length,
    );
  }
}
