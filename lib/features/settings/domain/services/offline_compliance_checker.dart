/// Utility to verify that settings features satisfy Offline-First requirements.
class OfflineComplianceChecker {
  /// Checks if a feature is fully functional without internet.
  static bool isOfflineCapable(String feature) {
    const compliant = [
      'loadSettings',
      'updateTheme',
      'updateCurrency',
      'toggleNotifications',
      'manageAppLock',
      'createLocalBackup',
      'accessibilityCustomization',
    ];
    return compliant.contains(feature);
  }
}
