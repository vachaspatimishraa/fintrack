import '../services/enterprise_certification.dart';
import '../services/quality_checklist.dart';

/// Final validator to run before code is merged for release.
class ReleaseValidator {
  /// Returns a list of release blockers if any exist.
  static List<String> getBlockers() {
    final List<String> blockers = [];
    
    final certification = EnterpriseCertification.certify();
    if (!certification['ProductionReady']) {
      blockers.add('Module failed enterprise certification.');
    }
    
    final quality = QualityChecklist.verify();
    if (quality.values.contains(false)) {
      blockers.add('One or more quality checklist items failed.');
    }
    
    return blockers;
  }
}
