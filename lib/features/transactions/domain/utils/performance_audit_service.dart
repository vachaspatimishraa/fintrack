class PerformanceAuditService {
  static bool runPerformanceAudit(int actualSaveMs, int actualSearchMs) {
    return actualSaveMs <= 150 && actualSearchMs <= 100;
  }
}
