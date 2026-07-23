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
      appLockEnabled: model.appLockEnabled,
      biometricEnabled: model.biometricEnabled,
      hasPin: model.hasPin,
      sessionTimeout: model.sessionTimeout,
      hideAccountBalances: model.hideAccountBalances,
      hideDashboardAmounts: model.hideDashboardAmounts,
      hideRecentTransactions: model.hideRecentTransactions,
      hideAnalyticsValues: model.hideAnalyticsValues,
      screenshotProtectionEnabled: model.screenshotProtectionEnabled,
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
      ..appLockEnabled = entity.appLockEnabled
      ..biometricEnabled = entity.biometricEnabled
      ..hasPin = entity.hasPin
      ..sessionTimeout = entity.sessionTimeout
      ..hideAccountBalances = entity.hideAccountBalances
      ..hideDashboardAmounts = entity.hideDashboardAmounts
      ..hideRecentTransactions = entity.hideRecentTransactions
      ..hideAnalyticsValues = entity.hideAnalyticsValues
      ..screenshotProtectionEnabled = entity.screenshotProtectionEnabled
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
