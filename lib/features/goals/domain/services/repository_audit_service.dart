import 'dart:developer';

/// Service to audit repository interactions for quality and performance.
class RepositoryAuditService {
  /// Records repository operation stats without logging sensitive values.
  static void logOperation(String method, {required bool success, int? durationMs}) {
    final status = success ? 'SUCCESS' : 'FAILURE';
    log('GoalsRepositoryAudit: $method | Status: $status | Duration: ${durationMs ?? 0}ms');
  }
}
