import 'notification_service.dart';
import '../entities/settings_entity.dart';
import 'quiet_hours_manager.dart';

class ReminderScheduler {
  final NotificationService _notificationService;

  ReminderScheduler(this._notificationService);

  Future<void> scheduleRecurringReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required SettingsEntity settings,
  }) async {
    if (!settings.masterNotificationsEnabled) return;
    
    // Check quiet hours before scheduling (Basic implementation)
    // In a real app, you might want to shift the time if it falls in quiet hours
    if (QuietHoursManager.isQuietTime(settings)) {
      // Logic to reschedule to next available non-quiet slot
    }

    await _notificationService.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  Future<void> cancelAll() async {
    await _notificationService.cancelAll();
  }
}
