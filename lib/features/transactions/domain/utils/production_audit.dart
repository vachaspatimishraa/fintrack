class ProductionAudit {
  static bool verifyProductionReady({
    required bool hasTestsPassed,
    required bool isOfflineCrudWorking,
    required bool isSyncQueueWorking,
    required bool isReceiptWorking,
  }) {
    return hasTestsPassed && isOfflineCrudWorking && isSyncQueueWorking && isReceiptWorking;
  }
}
