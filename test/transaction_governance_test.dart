import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/transactions/domain/utils/migration_manager.dart';
import 'package:fintrack/features/transactions/domain/utils/schema_version_manager.dart';
import 'package:fintrack/features/transactions/domain/utils/dependency_audit_service.dart';
import 'package:fintrack/features/transactions/domain/utils/performance_audit_service.dart';
import 'package:fintrack/features/transactions/domain/utils/security_audit_service.dart';
import 'package:fintrack/features/transactions/domain/utils/accessibility_audit_service.dart';
import 'package:fintrack/features/transactions/domain/utils/disaster_recovery_manager.dart';
import 'package:fintrack/features/transactions/domain/utils/backup_coordinator.dart';
import 'package:fintrack/features/transactions/domain/utils/governance_reporting.dart';

void main() {
  group('Transaction Module Governance & Maintenance Tests', () {
    test('MigrationManager and SchemaVersionManager execute safely', () {
      expect(MigrationManager.executeMigration(1, 2), isTrue);
      expect(SchemaVersionManager.checkSchemaMatch(1), isTrue);
      expect(SchemaVersionManager.checkSchemaMatch(2), isFalse);
    });

    test('DependencyAuditService audits dependency package whitelist', () {
      expect(DependencyAuditService.verifyDependencies(['flutter', 'isar', 'supabase_flutter']), isTrue);
      expect(DependencyAuditService.verifyDependencies(['flutter', 'some_unknown_package']), isFalse);
    });

    test('AuditServices verify parameters correctly', () {
      expect(PerformanceAuditService.runPerformanceAudit(120, 90), isTrue);
      expect(PerformanceAuditService.runPerformanceAudit(200, 90), isFalse);

      expect(SecurityAuditService.runSecurityAudit(rlsEnabled: true, sslUsed: true), isTrue);
      expect(AccessibilityAuditService.runAccessibilityAudit(hasSemantics: true, touchSize: 48.0), isTrue);
    });

    test('DisasterRecoveryManager and BackupCoordinator execute and return true', () {
      expect(DisasterRecoveryManager.handleCorruptedDatabase(), isTrue);
      expect(BackupCoordinator.triggerLocalSnapshot(), isTrue);
    });

    test('GovernanceReporting outputs correct release and threshold metadata', () {
      final releaseState = ReleaseChecklistGenerator.getReleaseState();
      expect(releaseState['all_tests_passed'], isTrue);

      expect(MonitoringDashboard.hasAlerts(0.002, 0.01), isFalse);
      expect(MonitoringDashboard.hasAlerts(0.02, 0.01), isTrue); // high crash alert

      expect(HealthReportService.generateSummaryReport(), contains('Crash Free Rate: 99.9%'));
      expect(TechnicalDebtReport.getRefactoringBudgetPercentage(), equals(20.0));
      expect(ChangelogGenerator.getChangelog(), contains('Version 1.0.0'));
      expect(ArchitectureDecisionRecordTemplate.getTemplate(), contains('ADR'));
    });
  });
}
