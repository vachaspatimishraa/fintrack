class GoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String status; // 'Active', 'Archived', 'Completed'
  final DateTime updatedAt;

  const GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.status,
    required this.updatedAt,
  });
}

class MilestoneModel {
  final String id;
  final String goalId;
  final String name;
  final double targetAmount;
  final bool isCompleted;

  const MilestoneModel({
    required this.id,
    required this.goalId,
    required this.name,
    required this.targetAmount,
    required this.isCompleted,
  });
}

class ContributionModel {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;

  const ContributionModel({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
  });
}

class GoalReminderModel {
  final String id;
  final String goalId;
  final String schedule; // 'daily', 'weekly', 'monthly'

  const GoalReminderModel({
    required this.id,
    required this.goalId,
    required this.schedule,
  });
}

class GoalProgressModel {
  final double completionPercentage;
  final double savingsRate;

  const GoalProgressModel({
    required this.completionPercentage,
    required this.savingsRate,
  });
}

class GoalForecastModel {
  final DateTime projectedCompletionDate;
  final double confidenceScore;

  const GoalForecastModel({
    required this.projectedCompletionDate,
    required this.confidenceScore,
  });
}

abstract class GoalsRepository {
  Future<List<GoalModel>> loadGoals();
  Stream<List<GoalModel>> watchGoals();
  Future<GoalModel> getGoal(String goalId);
  Future<void> createGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String goalId);
}

abstract class GoalsLocalDatasource {
  Future<void> saveGoal(GoalModel goal);
  Future<List<GoalModel>> loadGoals();
  Stream<List<GoalModel>> watchGoals();
  Future<void> deleteGoal(String goalId);
}

abstract class GoalsRemoteDatasource {
  Future<void> uploadGoals();
  Future<void> downloadGoals();
  Future<void> synchronize();
}

abstract class GoalEngine {
  Future<GoalProgressModel> calculateProgress(String goalId);
  Future<GoalForecastModel> forecast(String goalId);
}

abstract class GoalNotificationService {
  Future<void> scheduleReminder(GoalReminderModel reminder);
  Future<void> cancelReminder(String reminderId);
}
