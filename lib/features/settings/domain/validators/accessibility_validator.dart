import 'package:flutter/material.dart';

/// Validator for accessibility compliance in Settings UI.
class AccessibilityValidator {
  static const double minTouchTarget = 48.0;

  /// Verifies touch target dimensions.
  static bool validateTouchTarget(Size size) {
    return size.width >= minTouchTarget && size.height >= minTouchTarget;
  }

  /// Ensures a widget has an associated semantic label.
  static bool verifySemanticLabel(String? label) {
    return label != null && label.isNotEmpty;
  }
}
