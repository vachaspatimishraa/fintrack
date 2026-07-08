class PerformanceValidator {
  const PerformanceValidator();

  bool validateMetrics({
    required int dashboardMs,
    required int kpiMs,
    required int healthMs,
    required int insightMs,
    required int forecastMs,
  }) {
    if (dashboardMs > 150) return false;
    if (kpiMs > 40) return false;
    if (healthMs > 60) return false;
    if (insightMs > 120) return false;
    if (forecastMs > 100) return false;
    return true;
  }
}
