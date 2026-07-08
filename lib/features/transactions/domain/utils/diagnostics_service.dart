class DiagnosticsService {
  static Map<String, dynamic> collectDiagnostics({
    required int queueLength,
    required int averageWriteMs,
  }) {
    return {
      'sync_queue_size': queueLength,
      'average_write_latency_ms': averageWriteMs,
      'is_database_stable': averageWriteMs < 200,
    };
  }
}
