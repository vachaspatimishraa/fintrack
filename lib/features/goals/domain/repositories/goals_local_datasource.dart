import '../../../../core/database/isar/collections/goal_model.dart';

/// Contract for local persistent storage of goals and related entities.
abstract class GoalsLocalDatasource {
  // Goal methods
  Future<void> saveGoal(GoalModel goal);
  Future<List<GoalModel>> loadGoals(String ownerId);
  Stream<List<GoalModel>> watchGoals(String ownerId);
  Future<GoalModel?> findGoalByUuid(String uuid);
  Future<void> deleteGoal(String goalId);
  
  // Milestone methods
  Future<List<MilestoneModel>> loadMilestones(String goalId);
  Future<void> saveMilestone(MilestoneModel milestone);
  Future<void> deleteMilestone(String uuid);

  // Contribution methods
  Future<List<ContributionModel>> loadContributions(String goalId);
  Future<void> saveContribution(ContributionModel contribution);
  Future<void> deleteContribution(String uuid);
}
