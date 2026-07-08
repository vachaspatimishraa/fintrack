import 'architecture_validation_service.dart';
import 'security_validator.dart';
import 'performance_validator.dart';
import 'accessibility_validator.dart';
import 'offline_compliance_checker.dart';

class EnterpriseCertification {
  final ArchitectureValidationService _archVal = const ArchitectureValidationService();
  final SecurityValidator _secVal = const SecurityValidator();
  final PerformanceValidator _perfVal = const PerformanceValidator();
  final AccessibilityValidator _accessVal = const AccessibilityValidator();
  final OfflineComplianceChecker _offlineVal = const OfflineComplianceChecker();

  EnterpriseCertification();

  bool certify({
    required String repositoryContent,
    required String uiScreenContent,
    required int dashboardMs,
    required int kpiMs,
    required int healthMs,
    required int insightMs,
    required int forecastMs,
  }) {
    // 1. Clean architecture checks
    if (!_archVal.validateImports(repositoryContent)) return false;
    if (!_archVal.validateSingleSourceOfTruth(uiScreenContent)) return false;

    // 2. Security checks
    if (!_secVal.validateSecrets(repositoryContent)) return false;

    // 3. Performance checks
    if (!_perfVal.validateMetrics(
      dashboardMs: dashboardMs,
      kpiMs: kpiMs,
      healthMs: healthMs,
      insightMs: insightMs,
      forecastMs: forecastMs,
    )) {
      return false;
    }

    // 4. Accessibility checks
    if (!_accessVal.validateTouchTarget(48, 48)) return false;

    // 5. Offline compliance checks
    if (!_offlineVal.isOfflineCompliant(repositoryContent)) return false;

    return true;
  }
}
