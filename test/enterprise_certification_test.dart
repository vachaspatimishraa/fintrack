import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/architecture_validation_service.dart';
import 'package:fintrack/features/analytics/domain/utils/security_validator.dart';
import 'package:fintrack/features/analytics/domain/utils/performance_validator.dart';
import 'package:fintrack/features/analytics/domain/utils/accessibility_validator.dart';
import 'package:fintrack/features/analytics/domain/utils/offline_compliance_checker.dart';
import 'package:fintrack/features/analytics/domain/utils/enterprise_certification.dart';

void main() {
  group('ArchitectureValidationService Tests', () {
    const archVal = ArchitectureValidationService();

    test('rejects material design imports in clean domain/data layers', () {
      const badRepo = "import 'package:flutter/material.dart';\nclass AnalyticsRepositoryImpl {}";
      expect(archVal.validateImports(badRepo), false);

      const goodRepo = "import 'analytics_repository.dart';\nclass AnalyticsRepositoryImpl {}";
      expect(archVal.validateImports(goodRepo), true);
    });

    test('rejects direct database imports in screen layouts', () {
      const badScreen = "import 'package:isar/isar.dart';\nclass SpendingTrendScreen {}";
      expect(archVal.validateSingleSourceOfTruth(badScreen), false);

      const goodScreen = "import 'analytics_provider.dart';\nclass SpendingTrendScreen {}";
      expect(archVal.validateSingleSourceOfTruth(goodScreen), true);
    });
  });

  group('SecurityValidator Tests', () {
    const secVal = SecurityValidator();

    test('detects hardcoded keys or passwords in source content', () {
      const badContent = "final supabase_key = 'abcdef12345';";
      expect(secVal.validateSecrets(badContent), false);

      const goodContent = "final key = ref.watch(provider);";
      expect(secVal.validateSecrets(goodContent), true);
    });

    test('detects raw financial values printed inside logs', () {
      expect(secVal.validateLogPrivacy("User generated report with ₹2500 deficit"), false);
      expect(secVal.validateLogPrivacy("User generated report completed successfully"), true);
    });
  });

  group('PerformanceValidator Tests', () {
    const perfVal = PerformanceValidator();

    test('enforces calculations speed thresholds', () {
      // Good metrics: Dashboard 100ms, KPI 30ms, Health 50ms, Insight 110ms, Forecast 80ms
      expect(perfVal.validateMetrics(dashboardMs: 100, kpiMs: 30, healthMs: 50, insightMs: 110, forecastMs: 80), true);

      // Violates Dashboard target (>150ms)
      expect(perfVal.validateMetrics(dashboardMs: 200, kpiMs: 30, healthMs: 50, insightMs: 110, forecastMs: 80), false);
    });
  });

  group('AccessibilityValidator Tests', () {
    const accessVal = AccessibilityValidator();

    test('enforces touch target sizes minimum of 48dp', () {
      expect(accessVal.validateTouchTarget(48, 48), true);
      expect(accessVal.validateTouchTarget(40, 48), false);
    });
  });

  group('OfflineComplianceChecker Tests', () {
    const offlineVal = OfflineComplianceChecker();

    test('rejects network fetch requests in repository implementations', () {
      const badRepo = "final res = await http.get(Uri.parse(url));";
      expect(offlineVal.isOfflineCompliant(badRepo), false);

      const goodRepo = "final list = await _transactionRepository.getTransactions();";
      expect(offlineVal.isOfflineCompliant(goodRepo), true);
    });
  });

  group('EnterpriseCertification Tests', () {
    test('certifies release when all validators pass', () {
      final cert = EnterpriseCertification();

      final res = cert.certify(
        repositoryContent: "import 'analytics_repository.dart';\nclass AnalyticsRepositoryImpl {}",
        uiScreenContent: "import 'analytics_provider.dart';\nclass SpendingTrendScreen {}",
        dashboardMs: 100,
        kpiMs: 25,
        healthMs: 40,
        insightMs: 90,
        forecastMs: 70,
      );

      expect(res, true);
    });
  });
}
