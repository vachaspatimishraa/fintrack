import 'dart:developer';
import 'package:flutter/foundation.dart';

class SettingsPerformanceService {
  static void logTiming(String operation, int durationMs) {
    if (kDebugMode) {
      log('SettingsPerformance: $operation took ${durationMs}ms');
    }
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
