import 'dart:developer';
import '../utils/budget_performance_service.dart';

/// Service to audit repository interactions for quality and performance.
/// 
/// Records operation timings and result statuses without logging sensitive financial data.
class RepositoryAuditService {
  /// Audits a repository method call.
  static void audit(String methodName, {required bool success, int? durationMs}) {
    final status = success ? 'SUCCESS' : 'FAILURE';
    log('RepositoryAudit: $methodName | Status: $status | Time: ${durationMs ?? 0}ms');
    
    if (durationMs != null) {
      BudgetPerformanceService.logTiming(methodName, durationMs);
    }
  }
}
