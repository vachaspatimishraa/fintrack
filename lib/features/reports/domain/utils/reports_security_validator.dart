class ReportsSecurityValidator {
  const ReportsSecurityValidator();

  bool validateSecrets(String content) {
    final apiKeyPattern = RegExp("(api_key|supabase_key|jwt|token|password)\\s*=\\s*['\"].+['\"]", caseSensitive: false);
    if (apiKeyPattern.hasMatch(content)) {
      return false; // Sensitive data detected
    }
    return true;
  }

  bool validateLogPrivacy(String logMessage) {
    final monetaryPattern = RegExp(r"(₹|\$|rs\.?)\s*\d+", caseSensitive: false);
    if (monetaryPattern.hasMatch(logMessage)) {
      return false; // Violates data minimization log policies
    }
    return true;
  }
}
