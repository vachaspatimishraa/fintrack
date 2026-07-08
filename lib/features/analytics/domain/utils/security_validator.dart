class SecurityValidator {
  const SecurityValidator();

  bool validateSecrets(String content) {
    // Check for hardcoded API keys, tokens, or passwords
    final apiKeyPattern = RegExp("(api_key|supabase_key|jwt|token|password)\\s*=\\s*['\"].+['\"]", caseSensitive: false);
    if (apiKeyPattern.hasMatch(content)) {
      return false; // Sensitive data detected
    }
    return true;
  }

  bool validateLogPrivacy(String logMessage) {
    // Logs should never print transactional details, notes, or raw monetary numbers
    final monetaryPattern = RegExp(r"(₹|\$|rs\.?)\s*\d+", caseSensitive: false);
    if (monetaryPattern.hasMatch(logMessage)) {
      return false; // Violates data minimization and privacy logs policy
    }
    return true;
  }
}
