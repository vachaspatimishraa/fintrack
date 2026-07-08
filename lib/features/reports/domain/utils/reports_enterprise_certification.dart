import 'reports_architecture_validator.dart';
import 'reports_security_validator.dart';
import 'reports_performance_validator.dart';
import 'reports_accessibility_validator.dart';
import 'reports_offline_compliance_checker.dart';

class ReportsEnterpriseCertification {
  final ReportsArchitectureValidator _archVal = const ReportsArchitectureValidator();
  final ReportsSecurityValidator _secVal = const ReportsSecurityValidator();
  final ReportsPerformanceValidator _perfVal = const ReportsPerformanceValidator();
  final ReportsAccessibilityValidator _accessVal = const ReportsAccessibilityValidator();
  final ReportsOfflineComplianceChecker _offlineVal = const ReportsOfflineComplianceChecker();

  ReportsEnterpriseCertification();

  bool certify({
    required String repositoryContent,
    required String uiScreenContent,
    required int reportGenerationMs,
    required int previewGenerationMs,
    required int pdfExportMs,
    required int excelExportMs,
    required int csvExportMs,
  }) {
    if (!_archVal.validateImports(repositoryContent)) return false;
    if (!_archVal.validateSingleSourceOfTruth(uiScreenContent)) return false;

    if (!_secVal.validateSecrets(repositoryContent)) return false;

    if (!_perfVal.validateMetrics(
      reportGenerationMs: reportGenerationMs,
      previewGenerationMs: previewGenerationMs,
      pdfExportMs: pdfExportMs,
      excelExportMs: excelExportMs,
      csvExportMs: csvExportMs,
    )) {
      return false;
    }

    if (!_accessVal.validateTouchTarget(48, 48)) return false;

    if (!_offlineVal.isOfflineCompliant(repositoryContent)) return false;

    return true;
  }
}
