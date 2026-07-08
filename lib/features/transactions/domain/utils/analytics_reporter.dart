class AnalyticsReporter {
  static void reportPerformance(String operation, int durationMs) {
    // Telemetry trace (anonymized performance metric)
    print('[ANALYTICS PERF]: $operation took ${durationMs}ms');
  }

  static void reportError(String errorCode, String errorMessage) {
    // Telemetry crash/failure log
    print('[ANALYTICS ERROR]: Code: $errorCode | Msg: $errorMessage');
  }

  static void reportSyncQueueSize(int size) {
    print('[ANALYTICS SYNC]: Pending upload queue size is $size');
  }
}
