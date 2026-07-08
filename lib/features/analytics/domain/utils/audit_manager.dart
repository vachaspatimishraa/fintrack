class AuditEntry {
  final String auditId;
  final String module;
  final String action;
  final String status;
  final int durationMs;
  final DateTime timestamp;
  final String version;
  final String deviceId;
  final String syncStatus;

  const AuditEntry({
    required this.auditId,
    required this.module,
    required this.action,
    required this.status,
    required this.durationMs,
    required this.timestamp,
    required this.version,
    required this.deviceId,
    required this.syncStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'auditId': auditId,
      'module': module,
      'action': action,
      'status': status,
      'durationMs': durationMs,
      'timestamp': timestamp.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
      'syncStatus': syncStatus,
    };
  }
}

class AuditManager {
  static final AuditManager _instance = AuditManager._internal();
  factory AuditManager() => _instance;
  AuditManager._internal();

  final List<AuditEntry> _auditLogs = [];

  List<AuditEntry> get logs => List.unmodifiable(_auditLogs);

  void logEvent({
    required String module,
    required String action,
    required String status,
    required int durationMs,
    String version = '1.0.0',
    String deviceId = 'local-device',
    String syncStatus = 'synced',
  }) {
    // Sanitize action and details to ensure absolute data minimization
    final sanitizedAction = _sanitize(action);

    final entry = AuditEntry(
      auditId: DateTime.now().microsecondsSinceEpoch.toString(),
      module: module,
      action: sanitizedAction,
      status: status,
      durationMs: durationMs,
      timestamp: DateTime.now(),
      version: version,
      deviceId: deviceId,
      syncStatus: syncStatus,
    );

    _auditLogs.add(entry);
  }

  String _sanitize(String value) {
    // Strip raw transaction currency figures and notes
    return value
        .replaceAll(RegExp(r'\d+'), 'XXX')
        .replaceAll(RegExp(r'(\$|₹|rs\.?)', caseSensitive: false), 'CUR');
  }

  void clearLogs() {
    _auditLogs.clear();
  }
}
