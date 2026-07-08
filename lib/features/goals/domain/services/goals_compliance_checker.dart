/// Utility to check if goals module satisfies enterprise compliance rules.
class GoalsComplianceChecker {
  /// Verifies if the data minimization principle is followed in logging.
  static bool checkPrivacyCompliance(String logMessage) {
    final sensitiveKeywords = ['amount', 'password', 'note', 'token'];
    for (final word in sensitiveKeywords) {
      if (logMessage.toLowerCase().contains(word)) return false;
    }
    return true;
  }

  /// Checks if the module satisfies the minimum required goal categories.
  static bool hasRequiredCategories(List<String> categories) {
    const required = ['Savings', 'Debt', 'Investment', 'Business'];
    return required.every((item) => categories.contains(item));
  }
}
