/// Validator for performance benchmarks within the Goals Module.
class PerformanceValidator {
  static const int maxGoalLoadMs = 120;
  static const int maxGoalCreationMs = 50;
  static const int maxProgressCalcMs = 50;

  /// Validates if an operation's duration meets enterprise targets.
  static bool check(String operation, int durationMs) {
    if (operation == 'getGoals' && durationMs > maxGoalLoadMs) return false;
    if (operation == 'saveGoal' && durationMs > maxGoalCreationMs) return false;
    if (operation == 'calculateProgress' && durationMs > maxProgressCalcMs) return false;
    return true;
  }
}
