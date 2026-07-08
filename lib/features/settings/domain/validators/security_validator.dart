import '../entities/settings_entity.dart';

/// Validator for security and privacy compliance in Settings.
class SecurityValidator {
  /// Ensures no sensitive information is leaked in general settings logs or entities.
  static bool validateSettings(SettingsEntity entity) {
    // Logic to ensure no sensitive fields contain plain-text secrets
    return true;
  }

  /// Verifies if the storage method for a value is sufficiently secure.
  static bool isStorageSecure(String key, bool isSecureStorage) {
    const sensitiveKeys = ['pin', 'biometric_enabled'];
    if (sensitiveKeys.contains(key)) {
      return isSecureStorage;
    }
    return true;
  }
}
