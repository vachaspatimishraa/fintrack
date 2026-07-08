import 'dart:developer';
import 'package:flutter/foundation.dart';

class BudgetPerformanceService {
  static void logTiming(String operation, int durationMs) {
    if (kDebugMode) {
      log('BudgetPerformance: $operation took ${durationMs}ms');
    }
    // In production, we could send this to a monitoring tool like Firebase Performance
  }

  static Future<T> track<T>(String operation, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
      logTiming(operation, stopwatch.elapsedMilliseconds);
    }
  }
}
