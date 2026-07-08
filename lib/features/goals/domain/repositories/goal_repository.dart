import '../entities/goal_entity.dart';
import '../entities/milestone_entity.dart';
import '../entities/contribution_entity.dart';
import '../entities/goal_progress_model.dart';
import '../entities/goal_forecast_model.dart';
import '../entities/goal_analytics_model.dart';
import '../entities/goal_reminder_model.dart';
import '../entities/goal_template_model.dart';
import '../entities/goal_sync_status.dart';

/// Central repository for all goal-related operations.
/// 
/// This repository is the single source of truth for goals, milestones,
/// contributions, and synchronization status.
abstract class GoalRepository {
  // Goal Management APIs
  Future<List<GoalEntity>> loadGoals();
  Stream<List<GoalEntity>> watchGoals();
  Future<GoalEntity?> loadGoal(String goalId);
  Future<void> saveGoal(GoalEntity goal);
  Future<void> archiveGoal(String goalId);
  Future<void> restoreGoal(String goalId);
  Future<void> deleteGoal(String goalId);

  // Milestone APIs
  Future<List<MilestoneEntity>> loadMilestones(String goalId);
  Future<void> addMilestone(MilestoneEntity milestone);
  Future<void> updateMilestone(MilestoneEntity milestone);
  Future<void> deleteMilestone(String milestoneId);

  // Contribution APIs
  Future<void> addContribution(ContributionEntity contribution);
  Future<List<ContributionEntity>> loadContributions(String goalId);
  Future<void> updateContribution(ContributionEntity contribution);
  Future<void> deleteContribution(String contributionId);

  // Progress & Forecast APIs
  Future<GoalProgressModel> calculateProgress(String goalId);
  Future<GoalForecastModel> forecastCompletion(String goalId);
  
  // Notification APIs
  Future<void> scheduleGoalReminder(GoalReminderModel reminder);
  Future<void> cancelReminder(String reminderId);
  Future<void> updateReminder(GoalReminderModel reminder);
  Future<List<GoalReminderModel>> loadReminders();

  // Analytics APIs
  Future<GoalAnalyticsModel> generateAnalytics(String goalId);
  Future<Map<String, dynamic>> generateSummary();

  // Template APIs
  Future<List<GoalTemplateModel>> loadTemplates();
  Future<void> createTemplate(GoalTemplateModel template);
  Future<void> deleteTemplate(String templateId);
  Future<void> applyTemplate(String templateId);

  // Synchronization APIs
  Future<void> synchronize();
  Future<void> synchronizeGoals();
  Future<void> pauseSynchronization();
  Future<void> resumeSynchronization();
  Future<GoalSyncStatus> getSynchronizationStatus();
  Stream<GoalSyncStatus> watchSynchronization();
}
