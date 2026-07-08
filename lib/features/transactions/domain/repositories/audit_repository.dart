import '../entities/audit_log_model.dart';

abstract class AuditRepository {
  Future<void> saveAuditLog(AuditLog log);
  Future<List<AuditLog>> getAuditLogs();
}
