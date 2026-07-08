import 'dart:developer';

class AnalyticsPerformanceService {
  static final AnalyticsPerformanceService _instance = AnalyticsPerformanceService._internal();
  factory AnalyticsPerformanceService() => _instance;
  AnalyticsPerformanceService._internal();

  final Map<String, Stopwatch> _stopwatches = {};
  final List<String> _performanceLogs = [];

  void start(String label) {
    _stopwatches[label] = Stopwatch()..start();
  }

  int stop(String label) {
    final watch = _stopwatches[label];
    if (watch == null) return 0;
    watch.stop();
    final elapsedMs = watch.elapsedMilliseconds;
    _stopwatches.remove(label);

    final logMessage = 'PERF: [$label] completed in ${elapsedMs}ms';
    log(logMessage);
    _performanceLogs.add(logMessage);
    return elapsedMs;
  }

  List<String> getLogs() {
    return List.unmodifiable(_performanceLogs);
  }

  void clearLogs() {
    _performanceLogs.clear();
  }
}
