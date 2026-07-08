import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/transactions/domain/entities/audit_log_model.dart';
import 'package:fintrack/features/transactions/domain/utils/compliance_checker.dart';
import 'package:fintrack/features/transactions/domain/utils/observability_service.dart';
import 'package:fintrack/features/transactions/domain/utils/health_report_generator.dart';

void main() {
  group('Enterprise Compliance & Audit Trail Tests', () {
    test('AuditLog maps immutable parameters to JSON mapping keys', () {
      final log = AuditLog(
        id: 'audit-1',
        entityId: 'tx-1',
        entityType: 'transaction',
        action: 'CREATED',
        actorId: 'user-1',
        timestamp: DateTime(2026, 7, 1),
        deviceId: 'device-1',
        appVersion: '1.0.0',
        platform: 'Android',
        success: true,
      );

      final json = log.toJson();
      expect(json['id'], equals('audit-1'));
      expect(json['success'], isTrue);
      expect(json['timestamp'], equals('2026-07-01T00:00:00.000'));
    });

    test('ComplianceChecker rejects sensitive financial data keys', () {
      final badTelemetry = {
        'event': 'sync_queue',
        'amount': 250.0,
      };
      expect(ComplianceChecker.verifyAnonymity(badTelemetry), isFalse);

      final goodTelemetry = {
        'event': 'sync_queue',
        'duration_ms': 120,
      };
      expect(ComplianceChecker.verifyAnonymity(goodTelemetry), isTrue);
    });

    test('ObservabilityService returns correct health states', () {
      expect(ObservabilityService.determineHealthState(0.001), equals('Healthy'));
      expect(ObservabilityService.determineHealthState(0.005), equals('Warning'));
      expect(ObservabilityService.determineHealthState(0.05), equals('Critical'));
    });

    test('ReleaseValidator checks release gates thresholds', () {
      expect(
        ReleaseValidator.verifyReleaseGates(
          testCoverage: 95.0,
          hasAnalyzerErrors: false,
          hasMigrationFailure: false,
        ),
        isTrue,
      );

      expect(
        ReleaseValidator.verifyReleaseGates(
          testCoverage: 80.0,
          hasAnalyzerErrors: false,
          hasMigrationFailure: false,
        ),
        isFalse,
      );
    });

    test('PrivacyAudit flags PII fields in telemetry dumps', () {
      expect(PrivacyAudit.auditPII('No sensitive info'), isTrue);
      expect(PrivacyAudit.auditPII('User added amount 50'), isFalse);
    });
  });
}
