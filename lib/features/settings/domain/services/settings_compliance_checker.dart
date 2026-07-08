/// Utility to check if settings implementations comply with enterprise requirements.
class SettingsComplianceChecker {
  /// Verifies if a setting key is allowed to be synchronized to the cloud.
  static bool isSyncAllowed(String key) {
    const forbiddenKeys = [
      'pin',
      'biometricData',
      'auth_token',
      'password',
    ];
    return !forbiddenKeys.contains(key.toLowerCase());
  }

  /// Checks if the module satisfies the minimum required preference categories.
  static bool hasRequiredCategories(List<String> categories) {
    const required = [
      'Appearance',
      'Localization',
      'Notifications',
      'Security',
      'Backup',
      'Accessibility',
      'About',
    ];
    return required.every((item) => categories.contains(item));
  }
}
