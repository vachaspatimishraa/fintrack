class RepositoryLogger {
  static void logInfo(String message) {
    // Prints safe metadata only
    print('[Repository INFO]: $message');
  }

  static void logError(String message, [Object? error]) {
    print('[Repository ERROR]: $message ${error != null ? "- $error" : ""}');
  }

  static void logPerformance(String operation, int durationMs) {
    print('[Repository PERF]: $operation completed in ${durationMs}ms');
  }

  static Map<String, dynamic> sanitizePayload(Map<String, dynamic> payload) {
    final Map<String, dynamic> sanitized = Map<String, dynamic>.from(payload);
    // Redact sensitive financial data from log statements
    if (sanitized.containsKey('amount')) sanitized['amount'] = '[REDACTED]';
    if (sanitized.containsKey('description')) sanitized['description'] = '[REDACTED]';
    if (sanitized.containsKey('receipt_url')) sanitized['receipt_url'] = '[REDACTED]';
    if (sanitized.containsKey('receipt_local_path')) sanitized['receipt_local_path'] = '[REDACTED]';
    return sanitized;
  }
}
