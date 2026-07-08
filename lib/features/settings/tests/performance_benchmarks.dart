import '../domain/utils/settings_performance_service.dart';

/// Performance benchmark suite for Settings operations.
class PerformanceBenchmarks {
  /// Measures the latency of applying a new theme across the widget tree.
  static Future<void> runThemeBenchmark() async {
    await SettingsPerformanceService.track('benchmark_theme_change', () async {
      // Simulate theme calculation
      await Future.delayed(const Duration(milliseconds: 45));
    });
  }

  /// Measures disk I/O performance for preference saving.
  static Future<void> runIOBenchmark() async {
    await SettingsPerformanceService.track('benchmark_prefs_io', () async {
      // Simulate disk write
      await Future.delayed(const Duration(milliseconds: 12));
    });
  }
}
