import 'package:isar/isar.dart';

part 'settings_model.g.dart';

@collection
class SettingsModel {
  Id id = Isar.autoIncrement;

  late String themeMode;
  late bool dynamicColor;
  late bool amoledMode;
  late String currency;
  late String language;

  // Security & Privacy
  late bool appLockEnabled;
  late bool biometricEnabled;
  late bool hasPin;
  late String sessionTimeout;
  late bool hideAccountBalances;
  late bool hideDashboardAmounts;
  late bool hideRecentTransactions;
  late bool hideAnalyticsValues;
  late bool screenshotProtectionEnabled;

  late bool backupEnabled;
  late bool syncEnabled;
  late String displayDensity;
  late bool animationEnabled;
  late String iconStyle;

  late bool developerModeEnabled;
  late List<String> enabledFeatureFlags;

  late DateTime? lastSyncAt;
  
  @Index()
  late DateTime updatedAt;

  SettingsModel() {
    themeMode = 'system';
    dynamicColor = true;
    amoledMode = false;
    currency = 'INR';
    language = 'en';
    
    appLockEnabled = false;
    biometricEnabled = false;
    hasPin = false;
    sessionTimeout = '5_min';
    hideAccountBalances = false;
    hideDashboardAmounts = false;
    hideRecentTransactions = false;
    hideAnalyticsValues = false;
    screenshotProtectionEnabled = false;

    backupEnabled = true;
    syncEnabled = true;
    displayDensity = 'comfortable';
    animationEnabled = true;
    iconStyle = 'rounded';
    lastSyncAt = null;
    developerModeEnabled = false;
    enabledFeatureFlags = [];
    updatedAt = DateTime.now();
  }
}
