class AuditLog {
  final String id;
  final String entityId;
  final String entityType;
  final String action;
  final String actorId;
  final DateTime timestamp;
  final String deviceId;
  final String appVersion;
  final String platform;
  final bool success;
  final String? failureCode;

  const AuditLog({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.action,
    required this.actorId,
    required this.timestamp,
    required this.deviceId,
    required this.appVersion,
    required this.platform,
    required this.success,
    this.failureCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityId': entityId,
      'entityType': entityType,
      'action': action,
      'actorId': actorId,
      'timestamp': timestamp.toIso8601String(),
      'deviceId': deviceId,
      'appVersion': appVersion,
      'platform': platform,
      'success': success,
      'failureCode': failureCode,
    };
  }
}
