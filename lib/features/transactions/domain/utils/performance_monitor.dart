import 'repository_logger.dart';

class PerformanceMonitor {
  static Future<T> track<T>(String operation, Future<T> Function() action, {required int limitMs}) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;
      RepositoryLogger.logPerformance(operation, elapsed);
      if (elapsed > limitMs) {
        RepositoryLogger.logError('Performance Alert: $operation exceeded limit of ${limitMs}ms (took ${elapsed}ms)');
      }
    }
  }
}
