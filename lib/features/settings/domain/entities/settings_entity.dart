class SettingsEntity {
  final String themeMode; // system, light, dark, amoled
  final bool dynamicColor;
  final bool amoledMode;
  final String currency;
  final String language;
  
  // Notification Preferences
  final bool masterNotificationsEnabled;
  final bool budgetAlertsEnabled;
  final bool billRemindersEnabled;
  final bool recurringTransactionRemindersEnabled;
  final bool dailySummaryEnabled;
  final bool weeklySummaryEnabled;
  final bool monthlySummaryEnabled;
  final bool quietHoursEnabled;
  final String quietHoursStart; // "HH:mm"
  final String quietHoursEnd;   // "HH:mm"
  final bool notificationSoundEnabled;
  final bool notificationVibrationEnabled;

  // Security & Privacy
  final bool appLockEnabled;
  final bool biometricEnabled;
  final bool hasPin;
  final String sessionTimeout; // immediately, 1_min, 5_min, 15_min, 30_min, 1_hour, never
  final bool hideAccountBalances;
  final bool hideDashboardAmounts;
  final bool hideRecentTransactions;
  final bool hideAnalyticsValues;
  final bool screenshotProtectionEnabled;
  final bool securityNotificationsEnabled;

  // Accessibility
  final String fontScale; // small, default, large, extra_large
  final bool highContrast;
  final bool reduceMotion;
  final bool screenReaderHints;
  final String touchTargetSize; // normal, large
  final bool keyboardNavigationEnabled;
  final bool hapticFeedbackEnabled;

  final bool backupEnabled;
  final bool syncEnabled;
  final String displayDensity; // compact, comfortable, expanded
  final bool animationEnabled;
  final String iconStyle; // rounded, outlined
  final DateTime? lastSyncAt;
  final bool developerModeEnabled;
  final Map<String, bool> featureFlags;

  SettingsEntity({
    this.themeMode = 'system',
    this.dynamicColor = true,
    this.amoledMode = false,
    this.currency = 'INR',
    this.language = 'en',
    this.masterNotificationsEnabled = true,
    this.budgetAlertsEnabled = true,
    this.billRemindersEnabled = true,
    this.recurringTransactionRemindersEnabled = true,
    this.dailySummaryEnabled = true,
    this.weeklySummaryEnabled = false,
    this.monthlySummaryEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
    this.notificationSoundEnabled = true,
    this.notificationVibrationEnabled = true,
    this.appLockEnabled = false,
    this.biometricEnabled = false,
    this.hasPin = false,
    this.sessionTimeout = '5_min',
    this.hideAccountBalances = false,
    this.hideDashboardAmounts = false,
    this.hideRecentTransactions = false,
    this.hideAnalyticsValues = false,
    this.screenshotProtectionEnabled = false,
    this.securityNotificationsEnabled = true,
    this.fontScale = 'default',
    this.highContrast = false,
    this.reduceMotion = false,
    this.screenReaderHints = false,
    this.touchTargetSize = 'normal',
    this.keyboardNavigationEnabled = false,
    this.hapticFeedbackEnabled = true,
    this.backupEnabled = true,
    this.syncEnabled = true,
    this.displayDensity = 'comfortable',
    this.animationEnabled = true,
    this.iconStyle = 'rounded',
    this.lastSyncAt,
    this.developerModeEnabled = false,
    this.featureFlags = const {},
  });

  SettingsEntity copyWith({
    String? themeMode,
    bool? dynamicColor,
    bool? amoledMode,
    String? currency,
    String? language,
    bool? masterNotificationsEnabled,
    bool? budgetAlertsEnabled,
    bool? billRemindersEnabled,
    bool? recurringTransactionRemindersEnabled,
    bool? dailySummaryEnabled,
    bool? weeklySummaryEnabled,
    bool? monthlySummaryEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? notificationSoundEnabled,
    bool? notificationVibrationEnabled,
    bool? appLockEnabled,
    bool? biometricEnabled,
    bool? hasPin,
    String? sessionTimeout,
    bool? hideAccountBalances,
    bool? hideDashboardAmounts,
    bool? hideRecentTransactions,
    bool? hideAnalyticsValues,
    bool? screenshotProtectionEnabled,
    bool? securityNotificationsEnabled,
    String? fontScale,
    bool? highContrast,
    bool? reduceMotion,
    bool? screenReaderHints,
    String? touchTargetSize,
    bool? keyboardNavigationEnabled,
    bool? hapticFeedbackEnabled,
    bool? backupEnabled,
    bool? syncEnabled,
    String? displayDensity,
    bool? animationEnabled,
    String? iconStyle,
    DateTime? lastSyncAt,
    bool? developerModeEnabled,
    Map<String, bool>? featureFlags,
  }) {
    return SettingsEntity(
      themeMode: themeMode ?? this.themeMode,
      dynamicColor: dynamicColor ?? this.dynamicColor,
      amoledMode: amoledMode ?? this.amoledMode,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      masterNotificationsEnabled: masterNotificationsEnabled ?? this.masterNotificationsEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      billRemindersEnabled: billRemindersEnabled ?? this.billRemindersEnabled,
      recurringTransactionRemindersEnabled: recurringTransactionRemindersEnabled ?? this.recurringTransactionRemindersEnabled,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      monthlySummaryEnabled: monthlySummaryEnabled ?? this.monthlySummaryEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      notificationSoundEnabled: notificationSoundEnabled ?? this.notificationSoundEnabled,
      notificationVibrationEnabled: notificationVibrationEnabled ?? this.notificationVibrationEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      hasPin: hasPin ?? this.hasPin,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      hideAccountBalances: hideAccountBalances ?? this.hideAccountBalances,
      hideDashboardAmounts: hideDashboardAmounts ?? this.hideDashboardAmounts,
      hideRecentTransactions: hideRecentTransactions ?? this.hideRecentTransactions,
      hideAnalyticsValues: hideAnalyticsValues ?? this.hideAnalyticsValues,
      screenshotProtectionEnabled: screenshotProtectionEnabled ?? this.screenshotProtectionEnabled,
      securityNotificationsEnabled: securityNotificationsEnabled ?? this.securityNotificationsEnabled,
      fontScale: fontScale ?? this.fontScale,
      highContrast: highContrast ?? this.highContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      screenReaderHints: screenReaderHints ?? this.screenReaderHints,
      touchTargetSize: touchTargetSize ?? this.touchTargetSize,
      keyboardNavigationEnabled: keyboardNavigationEnabled ?? this.keyboardNavigationEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      backupEnabled: backupEnabled ?? this.backupEnabled,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      displayDensity: displayDensity ?? this.displayDensity,
      animationEnabled: animationEnabled ?? this.animationEnabled,
      iconStyle: iconStyle ?? this.iconStyle,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      developerModeEnabled: developerModeEnabled ?? this.developerModeEnabled,
      featureFlags: featureFlags ?? this.featureFlags,
    );
  }
}
