import 'notification_service.dart';
import '../entities/settings_entity.dart';

class BudgetAlertNotificationService {
  final NotificationService _notificationService;

  BudgetAlertNotificationService(this._notificationService);

  Future<void> sendBudgetWarning(String budgetName, double percent, SettingsEntity settings) async {
    if (!settings.masterNotificationsEnabled || !settings.budgetAlertsEnabled) return;

    await _notificationService.showInstantNotification(
      id: budgetName.hashCode,
      title: 'Budget Warning',
      body: 'Your budget "$budgetName" is at ${percent.toStringAsFixed(0)}% usage.',
      channelId: 'budget_alerts',
      channelName: 'Budget Alerts',
    );
  }
}
