class PerformanceBenchmark {
  static final Map<String, int> targetThresholds = {
    'save_transaction': 150,
    'delete_transaction': 100,
    'search_transaction': 100,
    'filter_transaction': 120,
    'preview_receipt': 300,
  };

  static bool verifyMetric(String operation, int actualDurationMs) {
    final limit = targetThresholds[operation];
    if (limit == null) return true;
    return actualDurationMs <= limit;
  }
}
