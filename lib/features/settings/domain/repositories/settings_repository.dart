import '../entities/settings_entity.dart';
import '../entities/app_information_entity.dart';
import '../entities/backup_history_entity.dart';

/// Central repository for all application configuration and user preferences.
abstract class SettingsRepository {
  // Core Settings
  Future<SettingsEntity> loadSettings();
  Stream<SettingsEntity> watchSettings();
  Future<void> updateSettings(SettingsEntity settings);
  Future<void> resetSettings();

  // Appearance
  Future<void> updateThemeMode(String mode);
  Future<void> updateDynamicColor(bool enabled);
  Future<void> updateAmoledMode(bool enabled);

  // Localization
  Future<void> updateCurrency(String currencyCode);
  Future<void> updateLanguage(String languageCode);

  // Security & Privacy
  Future<void> updateAppLock(bool enabled);
  Future<void> updateBiometric(bool enabled);
  Future<void> updatePin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> removePin();
  Future<void> updateSessionTimeout(String timeout);
  Future<void> updateHideAccountBalances(bool enabled);
  Future<void> updateHideDashboardAmounts(bool enabled);
  Future<void> updateHideRecentTransactions(bool enabled);
  Future<void> updateHideAnalyticsValues(bool enabled);
  Future<void> updateScreenshotProtection(bool enabled);

  // Backup & Sync
  Future<void> createBackup();
  Future<void> restoreBackup(String backupUuid);
  Future<List<BackupHistoryEntity>> getBackupHistory();
  Future<void> synchronize();
  Future<void> toggleSync(bool enabled);
  Future<void> toggleBackup(bool enabled);

  // About
  Future<AppInformationEntity> loadAppInformation();
  Future<String> loadPrivacyPolicy();
  Future<String> loadTermsOfService();
  Future<List<Map<String, String>>> loadReleaseNotes();

  // Developer
  Future<void> clearApplicationCache();
  Future<void> clearAnalyticsCache();
  Future<void> rebuildIndexes();
}
