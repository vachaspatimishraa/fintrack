class MetricsCollector {
  static Map<String, dynamic> collectTelemetry({
    required int saveTimeMs,
    required int searchTimeMs,
    required double memoryUsageMb,
  }) {
    return {
      'save_time_ms': saveTimeMs,
      'search_time_ms': searchTimeMs,
      'memory_usage_mb': memoryUsageMb,
    };
  }
}
