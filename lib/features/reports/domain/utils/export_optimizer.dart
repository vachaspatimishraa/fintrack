import 'package:flutter/foundation.dart';
import 'report_performance_service.dart';

class ExportOptimizer {
  const ExportOptimizer._();

  static Future<R> runInBackground<Q, R>(
    String label,
    ComputeCallback<Q, R> callback,
    Q message,
  ) async {
    final service = ReportPerformanceService();
    service.start(label);
    try {
      final result = await compute(callback, message);
      service.stop(label);
      return result;
    } catch (e) {
      service.stop(label);
      rethrow;
    }
  }
}
