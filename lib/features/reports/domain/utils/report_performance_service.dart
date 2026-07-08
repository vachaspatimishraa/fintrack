import 'dart:developer';

class ReportPerformanceService {
  static final ReportPerformanceService _instance = ReportPerformanceService._internal();
  factory ReportPerformanceService() => _instance;
  ReportPerformanceService._internal();

  final Map<String, Stopwatch> _watches = {};
  final List<String> _performanceLogs = [];

  void start(String label) {
    _watches[label] = Stopwatch()..start();
  }

  int stop(String label) {
    final watch = _watches[label];
    if (watch == null) return 0;
    watch.stop();
    final elapsedMs = watch.elapsedMilliseconds;
    _watches.remove(label);

    final logMessage = 'REPORTS_PERF: [$label] completed in ${elapsedMs}ms';
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
