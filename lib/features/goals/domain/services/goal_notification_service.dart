import '../entities/goal_reminder_model.dart';

/// Service responsible for managing system notifications for goals.
abstract class GoalNotificationService {
  /// Schedules a system reminder for a goal.
  Future<void> scheduleReminder(GoalReminderModel reminder);

  /// Cancels an existing scheduled reminder.
  Future<void> cancelReminder(String reminderId);
}
