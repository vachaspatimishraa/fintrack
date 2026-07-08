class ReportsAccessibilityValidator {
  const ReportsAccessibilityValidator();

  bool validateTouchTarget(double width, double height) {
    if (width < 48.0 || height < 48.0) {
      return false; // Minimum target size violated
    }
    return true;
  }
}
