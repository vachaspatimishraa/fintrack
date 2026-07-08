import 'package:package_info_plus/package_info_plus.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/entities/app_information_entity.dart';
import '../../domain/entities/backup_history_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/utils/settings_performance_service.dart';
import '../../domain/services/secure_storage_service.dart';
import '../../domain/repositories/settings_remote_datasource.dart';
import '../datasources/local/settings_local_datasource.dart';
import '../mappers/settings_mapper.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource _localDatasource;
  final SettingsRemoteDatasource _remoteDatasource;
  final BackupRepository _backupRepository;
  final SecureStorageService _secureStorage;
  
  SettingsEntity? _cachedSettings;

  SettingsRepositoryImpl({
    required SettingsLocalDatasource localDatasource,
    required SettingsRemoteDatasource remoteDatasource,
    required BackupRepository backupRepository,
    required SecureStorageService secureStorage,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _backupRepository = backupRepository,
        _secureStorage = secureStorage;

  @override
  Future<SettingsEntity> loadSettings() async {
    if (_cachedSettings != null) return _cachedSettings!;
    
    return SettingsPerformanceService.track('loadSettings', () async {
      final model = await _localDatasource.getSettings();
      _cachedSettings = SettingsMapper.toEntity(model);
      return _cachedSettings!;
    });
  }

  @override
  Stream<SettingsEntity> watchSettings() {
    return _localDatasource.watchSettings().map((model) {
      final entity = SettingsMapper.toEntity(model);
      _cachedSettings = entity;
      return entity;
    });
  }

  @override
  Future<void> updateSettings(SettingsEntity settings) async {
    return SettingsPerformanceService.track('updateSettings', () async {
      final model = SettingsMapper.toModel(settings);
      await _localDatasource.saveSettings(model);
      _cachedSettings = settings;
    });
  }

  @override
  Future<void> resetSettings() async {
    await _localDatasource.reset();
    await _secureStorage.clearAll();
    _cachedSettings = null;
  }

  // Appearance
  @override
  Future<void> updateThemeMode(String mode) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(themeMode: mode, amoledMode: mode == 'amoled'));
  }

  @override
  Future<void> updateDynamicColor(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(dynamicColor: enabled));
  }

  @override
  Future<void> updateAmoledMode(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(amoledMode: enabled));
  }

  @override
  Future<void> updateFontScale(String scale) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(fontScale: scale));
  }

  @override
  Future<void> updateDisplayDensity(String density) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(displayDensity: density));
  }

  @override
  Future<void> updateAnimationEnabled(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(animationEnabled: enabled));
  }

  // Localization
  @override
  Future<void> updateCurrency(String currencyCode) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(currency: currencyCode));
  }

  @override
  Future<void> updateLanguage(String languageCode) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(language: languageCode));
  }

  // Notifications
  @override
  Future<void> updateMasterNotification(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(masterNotificationsEnabled: enabled));
  }

  @override
  Future<void> updateBudgetAlerts(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(budgetAlertsEnabled: enabled));
  }

  @override
  Future<void> updateBillReminders(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(billRemindersEnabled: enabled));
  }

  @override
  Future<void> updateRecurringReminders(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(recurringTransactionRemindersEnabled: enabled));
  }

  @override
  Future<void> updateSummaryNotifications(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(dailySummaryEnabled: enabled));
  }

  @override
  Future<void> updateWeeklySummary(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(weeklySummaryEnabled: enabled));
  }

  @override
  Future<void> updateMonthlySummary(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(monthlySummaryEnabled: enabled));
  }

  @override
  Future<void> updateQuietHours(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(quietHoursEnabled: enabled));
  }

  @override
  Future<void> updateQuietHoursRange(String start, String end) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(quietHoursStart: start, quietHoursEnd: end));
  }

  @override
  Future<void> updateNotificationSound(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(notificationSoundEnabled: enabled));
  }

  @override
  Future<void> updateNotificationVibration(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(notificationVibrationEnabled: enabled));
  }

  // Security
  @override
  Future<void> updateAppLock(bool enabled) async {
    await _secureStorage.saveAppLockEnabled(enabled);
    final current = await loadSettings();
    await updateSettings(current.copyWith(appLockEnabled: enabled));
  }

  @override
  Future<void> updateBiometric(bool enabled) async {
    await _secureStorage.saveBiometricEnabled(enabled);
    final current = await loadSettings();
    await updateSettings(current.copyWith(biometricEnabled: enabled));
  }

  @override
  Future<void> updatePin(String pin) async {
    // Deprecated
  }

  @override
  Future<bool> verifyPin(String pin) async {
    return false;
  }

  @override
  Future<void> removePin() async {
    // Deprecated
  }

  @override
  Future<void> updateSessionTimeout(String timeout) async {
    await _secureStorage.saveTimeout(timeout);
    final current = await loadSettings();
    await updateSettings(current.copyWith(sessionTimeout: timeout));
  }

  @override
  Future<void> updateHideAccountBalances(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(hideAccountBalances: enabled));
  }

  @override
  Future<void> updateHideDashboardAmounts(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(hideDashboardAmounts: enabled));
  }

  @override
  Future<void> updateHideRecentTransactions(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(hideRecentTransactions: enabled));
  }

  @override
  Future<void> updateHideAnalyticsValues(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(hideAnalyticsValues: enabled));
  }

  @override
  Future<void> updateScreenshotProtection(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(screenshotProtectionEnabled: enabled));
  }

  // Backup & Sync
  @override
  Future<void> createBackup() async {
    await _backupRepository.createManualBackup();
  }

  @override
  Future<void> restoreBackup(String backupUuid) async {
    await _backupRepository.restoreFromBackup(backupUuid);
  }

  @override
  Future<List<BackupHistoryEntity>> getBackupHistory() async {
    return _backupRepository.getBackupHistory();
  }

  @override
  Future<void> synchronize() async {
    await _remoteDatasource.synchronize();
    await _backupRepository.triggerCloudSync();
  }

  @override
  Future<void> toggleSync(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(syncEnabled: enabled));
  }

  @override
  Future<void> toggleBackup(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(backupEnabled: enabled));
  }

  // Accessibility
  @override
  Future<void> updateHighContrast(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(highContrast: enabled));
  }

  @override
  Future<void> updateReduceMotion(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(reduceMotion: enabled));
  }

  @override
  Future<void> updateKeyboardNavigation(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(keyboardNavigationEnabled: enabled));
  }

  @override
  Future<void> updateTouchTargetSize(String size) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(touchTargetSize: size));
  }

  @override
  Future<void> updateHapticFeedback(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(hapticFeedbackEnabled: enabled));
  }

  @override
  Future<void> updateScreenReaderHints(bool enabled) async {
    final current = await loadSettings();
    await updateSettings(current.copyWith(screenReaderHints: enabled));
  }

  // About
  @override
  Future<AppInformationEntity> loadAppInformation() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return AppInformationEntity(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      buildDate: DateTime(2026, 7, 4),
    );
  }

  @override
  Future<String> loadPrivacyPolicy() async {
    return 'Privacy Policy...';
  }

  @override
  Future<String> loadTermsOfService() async {
    return 'Terms of Service...';
  }

  @override
  Future<List<Map<String, String>>> loadReleaseNotes() async {
    return [];
  }

  // Developer
  @override
  Future<void> clearApplicationCache() async {}
  @override
  Future<void> clearAnalyticsCache() async {}
  @override
  Future<void> rebuildIndexes() async {}
}
