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

  // Localization
  Future<void> updateCurrency(String currencyCode) async => _repository.updateCurrency(currencyCode);
  Future<void> updateLanguage(String languageCode) async => _repository.updateLanguage(languageCode);

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

  Future<void> resetSettings() async => _repository.resetSettings();
}

final settingsControllerProvider = Provider<SettingsController>((ref) => SettingsController(ref));
