import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../providers/settings_provider.dart';

class SettingsController {
  final Ref _ref;

  SettingsController(this._ref);

  SettingsRepository get _repository => _ref.read(settingsRepositoryProvider);

  // Appearance
  Future<void> updateThemeMode(String mode) async => _repository.updateThemeMode(mode);
  Future<void> updateDynamicColor(bool enabled) async => _repository.updateDynamicColor(enabled);
  Future<void> updateAmoledMode(bool enabled) async => _repository.updateAmoledMode(enabled);
  Future<void> updateFontScale(String scale) async => _repository.updateFontScale(scale);
  Future<void> updateDisplayDensity(String density) async => _repository.updateDisplayDensity(density);
  Future<void> updateAnimationEnabled(bool enabled) async => _repository.updateAnimationEnabled(enabled);

  // Localization
  Future<void> updateCurrency(String currencyCode) async => _repository.updateCurrency(currencyCode);
  Future<void> updateLanguage(String languageCode) async => _repository.updateLanguage(languageCode);

  // Notifications
  Future<void> toggleMasterNotifications(bool enabled) async => _repository.updateMasterNotification(enabled);
  Future<void> toggleBudgetAlerts(bool enabled) async => _repository.updateBudgetAlerts(enabled);
  Future<void> toggleBillReminders(bool enabled) async => _repository.updateBillReminders(enabled);
  Future<void> toggleRecurringReminders(bool enabled) async => _repository.updateRecurringReminders(enabled);
  Future<void> toggleDailySummary(bool enabled) async => _repository.updateSummaryNotifications(enabled);
  Future<void> toggleWeeklySummary(bool enabled) async => _repository.updateWeeklySummary(enabled);
  Future<void> toggleMonthlySummary(bool enabled) async => _repository.updateMonthlySummary(enabled);
  Future<void> toggleQuietHours(bool enabled) async => _repository.updateQuietHours(enabled);
  Future<void> updateQuietHoursRange(String start, String end) async => _repository.updateQuietHoursRange(start, end);
  Future<void> toggleNotificationSound(bool enabled) async => _repository.updateNotificationSound(enabled);
  Future<void> toggleNotificationVibration(bool enabled) async => _repository.updateNotificationVibration(enabled);

  // Security
  Future<void> toggleAppLock(bool enabled) async => _repository.updateAppLock(enabled);
  Future<void> toggleBiometricEnabled(bool enabled) async => _repository.updateBiometric(enabled);
  Future<void> setPin(String pin) async => _repository.updatePin(pin);
  Future<void> removePin() async => _repository.removePin();
  Future<void> updateSessionTimeout(String timeout) async => _repository.updateSessionTimeout(timeout);
  Future<void> toggleHideAccountBalances(bool enabled) async => _repository.updateHideAccountBalances(enabled);
  Future<void> toggleHideDashboardAmounts(bool enabled) async => _repository.updateHideDashboardAmounts(enabled);
  Future<void> toggleHideRecentTransactions(bool enabled) async => _repository.updateHideRecentTransactions(enabled);
  Future<void> toggleHideAnalyticsValues(bool enabled) async => _repository.updateHideAnalyticsValues(enabled);
  Future<void> toggleScreenshotProtection(bool enabled) async => _repository.updateScreenshotProtection(enabled);

  // Backup
  Future<void> toggleSync(bool enabled) async => _repository.toggleSync(enabled);
  Future<void> toggleBackup(bool enabled) async => _repository.toggleBackup(enabled);

  // Accessibility
  Future<void> toggleHighContrast(bool enabled) async => _repository.updateHighContrast(enabled);
  Future<void> toggleReduceMotion(bool enabled) async => _repository.updateReduceMotion(enabled);
  Future<void> toggleKeyboardNavigation(bool enabled) async => _repository.updateKeyboardNavigation(enabled);
  Future<void> updateTouchTargetSize(String size) async => _repository.updateTouchTargetSize(size);
  Future<void> toggleHapticFeedback(bool enabled) async => _repository.updateHapticFeedback(enabled);
  Future<void> toggleScreenReaderHints(bool enabled) async => _repository.updateScreenReaderHints(enabled);

  Future<void> resetSettings() async => _repository.resetSettings();
}

final settingsControllerProvider = Provider<SettingsController>((ref) => SettingsController(ref));
