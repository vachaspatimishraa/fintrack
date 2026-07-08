import '../entities/budget_entity.dart';

/// Validator for security compliance within the Budget Module.
/// 
/// Ensures that sensitive information like tokens or passwords are never handled
/// or stored by budget components.
class SecurityValidator {
  /// Validates that a budget entity contains no forbidden sensitive data.
  static bool validateEntity(BudgetEntity entity) {
    // Ensure no passwords or secrets are accidentally stored in descriptions or titles
    final forbiddenKeywords = ['password', 'secret', 'token', 'key'];
    final content = '${entity.title} ${entity.description ?? ''}'.toLowerCase();
    
    for (final keyword in forbiddenKeywords) {
      if (content.contains(keyword)) return false;
    }
    return true;
  }

  /// Verifies that logging does not contain sensitive data.
  static bool verifyLoggingSafety(String logMessage) {
    // Placeholder for actual log auditing logic
    return !logMessage.contains('amount') && !logMessage.contains('balance');
  }
}
