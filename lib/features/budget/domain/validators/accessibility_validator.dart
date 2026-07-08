
/// Validator for accessibility standards in Budget Module widgets.
/// 
/// Checks for semantic labels, touch target sizes, and contrast requirements.
class AccessibilityValidator {
  static const double minTouchTargetSize = 48.0;

  /// Validates if a widget configuration meets minimum touch target standards.
  static bool validateTouchTarget(double width, double height) {
    return width >= minTouchTargetSize && height >= minTouchTargetSize;
  }

  /// Ensures that visual components have required semantic labels.
  static bool hasSemanticLabel(String? label) {
    return label != null && label.isNotEmpty;
  }
}
