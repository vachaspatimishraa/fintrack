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

  // Notification Preferences
  late bool masterNotificationsEnabled;
  late bool budgetAlertsEnabled;
  late bool billRemindersEnabled;
  late bool recurringTransactionRemindersEnabled;
  late bool dailySummaryEnabled;
  late bool weeklySummaryEnabled;
  late bool monthlySummaryEnabled;
  late bool quietHoursEnabled;
  late String quietHoursStart;
  late String quietHoursEnd;
  late bool notificationSoundEnabled;
  late bool notificationVibrationEnabled;

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
  late bool securityNotificationsEnabled;

  // Accessibility
  late String fontScale;
  late bool highContrast;
  late bool reduceMotion;
  late bool screenReaderHints;
  late String touchTargetSize;
  late bool keyboardNavigationEnabled;
  late bool hapticFeedbackEnabled;

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
    currency = 'USD';
    language = 'en';
    masterNotificationsEnabled = true;
    budgetAlertsEnabled = true;
    billRemindersEnabled = true;
    recurringTransactionRemindersEnabled = true;
    dailySummaryEnabled = true;
    weeklySummaryEnabled = false;
    monthlySummaryEnabled = true;
    quietHoursEnabled = false;
    quietHoursStart = '22:00';
    quietHoursEnd = '07:00';
    notificationSoundEnabled = true;
    notificationVibrationEnabled = true;
    
    appLockEnabled = false;
    biometricEnabled = false;
    hasPin = false;
    sessionTimeout = '5_min';
    hideAccountBalances = false;
    hideDashboardAmounts = false;
    hideRecentTransactions = false;
    hideAnalyticsValues = false;
    screenshotProtectionEnabled = false;
    securityNotificationsEnabled = true;

    fontScale = 'default';
    highContrast = false;
    reduceMotion = false;
    screenReaderHints = false;
    touchTargetSize = 'normal';
    keyboardNavigationEnabled = false;
    hapticFeedbackEnabled = true;

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
