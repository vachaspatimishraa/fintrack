/// Validator for performance benchmarks in Settings.
class PerformanceValidator {
  static const int maxScreenLoadMs = 80;
  static const int maxPreferenceSaveMs = 30;
  static const int maxThemeChangeMs = 100;

  /// Validates if an operation's duration meets targets.
  static bool check(String operation, int durationMs) {
    switch (operation) {
      case 'loadSettings':
        return durationMs <= maxScreenLoadMs;
      case 'updateSettings':
        return durationMs <= maxPreferenceSaveMs;
      case 'themeChange':
        return durationMs <= maxThemeChangeMs;
      default:
        return true;
    }
  }
}
