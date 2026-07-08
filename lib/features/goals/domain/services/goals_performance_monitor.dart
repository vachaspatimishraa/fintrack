import '../utils/goals_performance_service.dart';

class GoalsPerformanceMonitor {
  static void logStartupTime(int durationMs) {
    GoalsPerformanceService.logTiming('goals_module_startup', durationMs);
  }

  static void logCacheStats(int hits, int misses) {
    final rate = (hits / (hits + misses)) * 100;
    GoalsPerformanceService.logTiming('cache_hit_rate', rate.toInt());
  }

  static void logSyncTime(int durationMs) {
    GoalsPerformanceService.logTiming('goals_synchronization', durationMs);
  }
}
