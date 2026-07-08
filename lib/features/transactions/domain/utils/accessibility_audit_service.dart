class AccessibilityAuditService {
  static bool runAccessibilityAudit({required bool hasSemantics, required double touchSize}) {
    return hasSemantics && touchSize >= 48.0;
  }
}
