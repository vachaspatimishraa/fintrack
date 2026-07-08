
/// Validator for accessibility compliance in Goals widgets.
class AccessibilityValidator {
  static const double minTouchTargetSize = 48.0;

  /// Verifies touch target dimensions for interactive elements.
  static bool validateTouchTarget(double width, double height) {
    return width >= minTouchTargetSize && height >= minTouchTargetSize;
  }

  /// Ensures that components have necessary semantic labels.
  static bool hasSemanticLabel(String? label) {
    return label != null && label.trim().isNotEmpty;
  }
}
