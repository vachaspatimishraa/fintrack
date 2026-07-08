import '../../../../core/database/isar/collections/settings_model.dart';
import '../../domain/entities/settings_entity.dart';

class SettingsMapper {
  static SettingsEntity toEntity(SettingsModel model) {
    return SettingsEntity(
      themeMode: model.themeMode,
      dynamicColor: model.dynamicColor,
      amoledMode: model.amoledMode,
      currency: model.currency,
      language: model.language,
      masterNotificationsEnabled: model.masterNotificationsEnabled,
      budgetAlertsEnabled: model.budgetAlertsEnabled,
      billRemindersEnabled: model.billRemindersEnabled,
      recurringTransactionRemindersEnabled: model.recurringTransactionRemindersEnabled,
      dailySummaryEnabled: model.dailySummaryEnabled,
      weeklySummaryEnabled: model.weeklySummaryEnabled,
      monthlySummaryEnabled: model.monthlySummaryEnabled,
      quietHoursEnabled: model.quietHoursEnabled,
      quietHoursStart: model.quietHoursStart,
      quietHoursEnd: model.quietHoursEnd,
      notificationSoundEnabled: model.notificationSoundEnabled,
      notificationVibrationEnabled: model.notificationVibrationEnabled,
      appLockEnabled: model.appLockEnabled,
      biometricEnabled: model.biometricEnabled,
      hasPin: model.hasPin,
      sessionTimeout: model.sessionTimeout,
      hideAccountBalances: model.hideAccountBalances,
      hideDashboardAmounts: model.hideDashboardAmounts,
      hideRecentTransactions: model.hideRecentTransactions,
      hideAnalyticsValues: model.hideAnalyticsValues,
      screenshotProtectionEnabled: model.screenshotProtectionEnabled,
      securityNotificationsEnabled: model.securityNotificationsEnabled,
      fontScale: model.fontScale,
      highContrast: model.highContrast,
      reduceMotion: model.reduceMotion,
      screenReaderHints: model.screenReaderHints,
      touchTargetSize: model.touchTargetSize,
      keyboardNavigationEnabled: model.keyboardNavigationEnabled,
      hapticFeedbackEnabled: model.hapticFeedbackEnabled,
      backupEnabled: model.backupEnabled,
      syncEnabled: model.syncEnabled,
      displayDensity: model.displayDensity,
      animationEnabled: model.animationEnabled,
      iconStyle: model.iconStyle,
      lastSyncAt: model.lastSyncAt,
      developerModeEnabled: model.developerModeEnabled,
      featureFlags: {for (var flag in model.enabledFeatureFlags) flag: true},
    );
  }

  static SettingsModel toModel(SettingsEntity entity) {
    return SettingsModel()
      ..themeMode = entity.themeMode
      ..dynamicColor = entity.dynamicColor
      ..amoledMode = entity.amoledMode
      ..currency = entity.currency
      ..language = entity.language
      ..masterNotificationsEnabled = entity.masterNotificationsEnabled
      ..budgetAlertsEnabled = entity.budgetAlertsEnabled
      ..billRemindersEnabled = entity.billRemindersEnabled
      ..recurringTransactionRemindersEnabled = entity.recurringTransactionRemindersEnabled
      ..dailySummaryEnabled = entity.dailySummaryEnabled
      ..weeklySummaryEnabled = entity.weeklySummaryEnabled
      ..monthlySummaryEnabled = entity.monthlySummaryEnabled
      ..quietHoursEnabled = entity.quietHoursEnabled
      ..quietHoursStart = entity.quietHoursStart
      ..quietHoursEnd = entity.quietHoursEnd
      ..notificationSoundEnabled = entity.notificationSoundEnabled
      ..notificationVibrationEnabled = entity.notificationVibrationEnabled
      ..appLockEnabled = entity.appLockEnabled
      ..biometricEnabled = entity.biometricEnabled
      ..hasPin = entity.hasPin
      ..sessionTimeout = entity.sessionTimeout
      ..hideAccountBalances = entity.hideAccountBalances
      ..hideDashboardAmounts = entity.hideDashboardAmounts
      ..hideRecentTransactions = entity.hideRecentTransactions
      ..hideAnalyticsValues = entity.hideAnalyticsValues
      ..screenshotProtectionEnabled = entity.screenshotProtectionEnabled
      ..securityNotificationsEnabled = entity.securityNotificationsEnabled
      ..fontScale = entity.fontScale
      ..highContrast = entity.highContrast
      ..reduceMotion = entity.reduceMotion
      ..screenReaderHints = entity.screenReaderHints
      ..touchTargetSize = entity.touchTargetSize
      ..keyboardNavigationEnabled = entity.keyboardNavigationEnabled
      ..hapticFeedbackEnabled = entity.hapticFeedbackEnabled
      ..backupEnabled = entity.backupEnabled
      ..syncEnabled = entity.syncEnabled
      ..displayDensity = entity.displayDensity
      ..animationEnabled = entity.animationEnabled
      ..iconStyle = entity.iconStyle
      ..lastSyncAt = entity.lastSyncAt
      ..developerModeEnabled = entity.developerModeEnabled
      ..enabledFeatureFlags = entity.featureFlags.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList()
      ..updatedAt = DateTime.now();
  }
}
