class SettingsEntity {
  final String themeMode; // system, light, dark, amoled
  final bool dynamicColor;
  final bool amoledMode;
  final String currency;
  final String language;
  
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
    this.appLockEnabled = false,
    this.biometricEnabled = false,
    this.hasPin = false,
    this.sessionTimeout = '5_min',
    this.hideAccountBalances = false,
    this.hideDashboardAmounts = false,
    this.hideRecentTransactions = false,
    this.hideAnalyticsValues = false,
    this.screenshotProtectionEnabled = false,
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
    bool? appLockEnabled,
    bool? biometricEnabled,
    bool? hasPin,
    String? sessionTimeout,
    bool? hideAccountBalances,
    bool? hideDashboardAmounts,
    bool? hideRecentTransactions,
    bool? hideAnalyticsValues,
    bool? screenshotProtectionEnabled,
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
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      hasPin: hasPin ?? this.hasPin,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      hideAccountBalances: hideAccountBalances ?? this.hideAccountBalances,
      hideDashboardAmounts: hideDashboardAmounts ?? this.hideDashboardAmounts,
      hideRecentTransactions: hideRecentTransactions ?? this.hideRecentTransactions,
      hideAnalyticsValues: hideAnalyticsValues ?? this.hideAnalyticsValues,
      screenshotProtectionEnabled: screenshotProtectionEnabled ?? this.screenshotProtectionEnabled,
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
