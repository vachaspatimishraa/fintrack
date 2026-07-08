
/// Validator for performance benchmarks within the Budget Module.
/// 
/// Monitors execution time for CRUD, queries, and calculations to ensure
/// responsiveness targets are met.
class PerformanceValidator {
  static const int maxDashboardLoadMs = 150;
  static const int maxCrudMs = 80;
  static const int maxProgressCalcMs = 20;

  /// Validates if an operation's duration meets enterprise standards.
  static bool check(String operation, int durationMs) {
    if (operation == 'getBudgetDashboard' && durationMs > maxDashboardLoadMs) return false;
    if (operation.startsWith('create') && durationMs > maxCrudMs) return false;
    if (operation == 'calculateProgress' && durationMs > maxProgressCalcMs) return false;
    return true;
  }
}
