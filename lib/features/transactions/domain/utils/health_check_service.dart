class HealthCheckService {
  static bool verifyStatus(Map<String, dynamic> diagnostics) {
    return (diagnostics['is_database_stable'] as bool? ?? false) &&
        (diagnostics['sync_queue_size'] as int? ?? 0) < 100;
  }
}
