import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';
import '../../providers/settings_provider.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/services/notification_permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  final _permissionService = NotificationPermissionService();
  PermissionStatus _status = PermissionStatus.provisional;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await _permissionService.getStatus();
    if (mounted) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (_status == PermissionStatus.denied || _status == PermissionStatus.permanentlyDenied)
              _buildPermissionWarning(),
            _buildMasterSwitch(settings),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Alert Categories'),
            _buildAlertCategories(settings),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Summaries'),
            _buildSummarySettings(settings),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Time & Behavior'),
            _buildBehaviorSettings(context, settings),
            const SizedBox(height: 48),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildPermissionWarning() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
        title: const Text('System Notifications Denied'),
        subtitle: const Text('FinTrack cannot send alerts because system permission is disabled.'),
        trailing: TextButton(
          onPressed: () async {
            await _permissionService.openSettings();
            _checkPermission();
          },
          child: const Text('Open Settings'),
        ),
      ),
    );
  }

  Widget _buildMasterSwitch(SettingsEntity settings) {
    return Card(
      child: SwitchListTile(
        title: const Text('Enable All Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Global control for all application alerts'),
        value: settings.masterNotificationsEnabled,
        onChanged: (val) => ref.read(settingsControllerProvider).toggleMasterNotifications(val),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildAlertCategories(SettingsEntity settings) {
    final controller = ref.read(settingsControllerProvider);
    final enabled = settings.masterNotificationsEnabled;

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Budget Alerts'),
            subtitle: const Text('Notify when reaching usage thresholds (80%, 90%)'),
            value: settings.budgetAlertsEnabled,
            onChanged: enabled ? (val) => controller.toggleBudgetAlerts(val) : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Bill Reminders'),
            subtitle: const Text('Alerts for upcoming utility and bill payments'),
            value: settings.billRemindersEnabled,
            onChanged: enabled ? (val) => controller.toggleBillReminders(val) : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Recurring Transactions'),
            subtitle: const Text('Reminders for subscriptions and regular transfers'),
            value: settings.recurringTransactionRemindersEnabled,
            onChanged: enabled ? (val) => controller.toggleRecurringReminders(val) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySettings(SettingsEntity settings) {
    final controller = ref.read(settingsControllerProvider);
    final enabled = settings.masterNotificationsEnabled;

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Daily Summary'),
            value: settings.dailySummaryEnabled,
            onChanged: enabled ? (val) => controller.toggleDailySummary(val) : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Weekly Digest'),
            value: settings.weeklySummaryEnabled,
            onChanged: enabled ? (val) => controller.toggleWeeklySummary(val) : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Monthly Report'),
            value: settings.monthlySummaryEnabled,
            onChanged: enabled ? (val) => controller.toggleMonthlySummary(val) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorSettings(BuildContext context, SettingsEntity settings) {
    final controller = ref.read(settingsControllerProvider);
    final enabled = settings.masterNotificationsEnabled;

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Quiet Hours'),
            subtitle: Text('Silence alerts between ${settings.quietHoursStart} and ${settings.quietHoursEnd}'),
            value: settings.quietHoursEnabled,
            onChanged: enabled ? (val) => controller.toggleQuietHours(val) : null,
          ),
          if (settings.quietHoursEnabled && enabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectQuietTime(context, true, settings.quietHoursStart),
                      child: Text('Starts at ${settings.quietHoursStart}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectQuietTime(context, false, settings.quietHoursEnd),
                      child: Text('Ends at ${settings.quietHoursEnd}'),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Notification Sound'),
            value: settings.notificationSoundEnabled,
            onChanged: enabled ? (val) => controller.toggleNotificationSound(val) : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Vibration'),
            value: settings.notificationVibrationEnabled,
            onChanged: enabled ? (val) => controller.toggleNotificationVibration(val) : null,
          ),
        ],
      ),
    );
  }

  Future<void> _selectQuietTime(BuildContext context, bool isStart, String currentTime) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      final settings = await ref.read(settingsRepositoryProvider).loadSettings();
      
      if (isStart) {
        ref.read(settingsControllerProvider).updateQuietHoursRange(formattedTime, settings.quietHoursEnd);
      } else {
        ref.read(settingsControllerProvider).updateQuietHoursRange(settings.quietHoursStart, formattedTime);
      }
    }
  }
}
