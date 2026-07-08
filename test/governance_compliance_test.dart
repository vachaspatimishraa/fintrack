import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/audit_manager.dart';
import 'package:fintrack/features/analytics/domain/utils/governance_service.dart';

void main() {
  group('AuditManager Governance Tests', () {
    test('logs audit events and sanitizes sensitive financial amounts', () {
      final manager = AuditManager();
      manager.clearLogs();

      manager.logEvent(
        module: 'analytics_reports',
        action: 'Generated monthly report for ₹25000',
        status: 'success',
        durationMs: 45,
      );

      expect(manager.logs.length, 1);
      final log = manager.logs.first;

      expect(log.module, 'analytics_reports');
      // Verifies '₹25000' is sanitized to 'CURXXX' to maintain log privacy rules
      expect(log.action.contains('25000'), false);
      expect(log.action.contains('₹'), false);
      expect(log.action, 'Generated monthly report for CURXXX');
    });
  });

  group('GovernanceService Tests', () {
    const gov = GovernanceService();

    test('enforces read-only database operations inside calculation engines', () {
      const badEngineCode = '''
class AnalyticsEngine {
  void addMetrics() {}
  Future<void> createTransaction() async {}
}
''';
      expect(gov.checkReadOnlyBoundary(badEngineCode), false);

      const goodEngineCode = '''
class AnalyticsEngine {
  MonthlyReport calculate() {}
}
''';
      expect(gov.checkReadOnlyBoundary(goodEngineCode), true);
    });

    test('enforces backward compatibility checking', () {
      expect(gov.checkVersionCompatibility(1), true); // Equal version
      expect(gov.checkVersionCompatibility(2), false); // Future version is incompatible
    });
  });
}
