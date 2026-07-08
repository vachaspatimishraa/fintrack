import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/reports/domain/utils/reports_architecture_validator.dart';
import 'package:fintrack/features/reports/domain/utils/reports_security_validator.dart';
import 'package:fintrack/features/reports/domain/utils/reports_performance_validator.dart';
import 'package:fintrack/features/reports/domain/utils/reports_accessibility_validator.dart';
import 'package:fintrack/features/reports/domain/utils/reports_offline_compliance_checker.dart';
import 'package:fintrack/features/reports/domain/utils/reports_enterprise_certification.dart';

void main() {
  group('ReportsArchitectureValidator Tests', () {
    const archVal = ReportsArchitectureValidator();

    test('rejects material design imports in clean domain/data layers', () {
      const badRepo = "import 'package:flutter/material.dart';\nclass ReportHistoryRepositoryImpl {}";
      expect(archVal.validateImports(badRepo), false);

      const goodRepo = "import 'report_history_repository.dart';\nclass ReportHistoryRepositoryImpl {}";
      expect(archVal.validateImports(goodRepo), true);
    });

    test('rejects direct database imports in screen layouts', () {
      const badScreen = "import 'package:isar/isar.dart';\nclass ReportHistoryScreen {}";
      expect(archVal.validateSingleSourceOfTruth(badScreen), false);

      const goodScreen = "import 'report_history_provider.dart';\nclass ReportHistoryScreen {}";
      expect(archVal.validateSingleSourceOfTruth(goodScreen), true);
    });
  });

  group('ReportsSecurityValidator Tests', () {
    const secVal = ReportsSecurityValidator();

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

  group('ReportsPerformanceValidator Tests', () {
    const perfVal = ReportsPerformanceValidator();

    test('enforces calculations speed thresholds', () {
      expect(
        perfVal.validateMetrics(
          reportGenerationMs: 300,
          previewGenerationMs: 250,
          pdfExportMs: 1500,
          excelExportMs: 800,
          csvExportMs: 300,
        ),
        true,
      );

      // Violates PDF export target (>2s)
      expect(
        perfVal.validateMetrics(
          reportGenerationMs: 300,
          previewGenerationMs: 250,
          pdfExportMs: 2500,
          excelExportMs: 800,
          csvExportMs: 300,
        ),
        false,
      );
    });
  });

  group('ReportsAccessibilityValidator Tests', () {
    const accessVal = ReportsAccessibilityValidator();

    test('enforces touch target sizes minimum of 48dp', () {
      expect(accessVal.validateTouchTarget(48, 48), true);
      expect(accessVal.validateTouchTarget(40, 48), false);
    });
  });

  group('ReportsOfflineComplianceChecker Tests', () {
    const offlineVal = ReportsOfflineComplianceChecker();

    test('rejects network fetch requests in repository implementations', () {
      const badRepo = "final res = await http.get(Uri.parse(url));";
      expect(offlineVal.isOfflineCompliant(badRepo), false);

      const goodRepo = "final list = await _historyRepository.getHistory();";
      expect(offlineVal.isOfflineCompliant(goodRepo), true);
    });
  });

  group('ReportsEnterpriseCertification Tests', () {
    test('certifies release when all validators pass', () {
      final cert = ReportsEnterpriseCertification();

      final res = cert.certify(
        repositoryContent: "import 'report_history_repository.dart';\nclass ReportHistoryRepositoryImpl {}",
        uiScreenContent: "import 'report_history_provider.dart';\nclass ReportHistoryScreen {}",
        reportGenerationMs: 300,
        previewGenerationMs: 200,
        pdfExportMs: 1200,
        excelExportMs: 600,
        csvExportMs: 200,
      );

      expect(res, true);
    });
  });
}
