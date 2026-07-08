class ComplianceChecker {
  static bool verifyAnonymity(Map<String, dynamic> telemetryData) {
    final sensitiveKeys = {'amount', 'notes', 'description', 'receipt_url', 'receipt_local_path'};
    for (final key in telemetryData.keys) {
      if (sensitiveKeys.contains(key.toLowerCase())) {
        return false;
      }
    }
    return true;
  }
}
