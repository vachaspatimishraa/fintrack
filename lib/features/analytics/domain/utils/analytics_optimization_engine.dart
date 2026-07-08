import 'package:flutter/foundation.dart';
import 'analytics_performance_service.dart';

class AnalyticsOptimizationEngine {
  const AnalyticsOptimizationEngine._();

  static Future<R> runInBackground<Q, R>(
    String label,
    ComputeCallback<Q, R> callback,
    Q message,
  ) async {
    final perf = AnalyticsPerformanceService();
    perf.start(label);
    try {
      final result = await compute(callback, message);
      perf.stop(label);
      return result;
    } catch (e) {
      perf.stop(label);
      rethrow;
    }
  }
}
