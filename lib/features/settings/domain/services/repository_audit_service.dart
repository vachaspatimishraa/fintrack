import 'dart:developer';

/// Service to audit repository interactions for timing and success rates.
class RepositoryAuditService {
  /// Records a repository operation event.
  static void logOperation(String method, {required bool success, int? durationMs}) {
    final status = success ? 'SUCCESS' : 'FAILURE';
    log('SettingsAudit: $method | Status: $status | Time: ${durationMs ?? 0}ms');
  }
}
