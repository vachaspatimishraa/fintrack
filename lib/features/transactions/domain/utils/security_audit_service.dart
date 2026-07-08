class SecurityAuditService {
  static bool runSecurityAudit({required bool rlsEnabled, required bool sslUsed}) {
    return rlsEnabled && sslUsed;
  }
}
