class ReportsOfflineComplianceChecker {
  const ReportsOfflineComplianceChecker();

  bool isOfflineCompliant(String fileContent) {
    if (fileContent.contains('http.get') ||
        fileContent.contains('client.from') ||
        fileContent.contains('fetchUrl')) {
      return false; // Direct cloud queries violate offline-first architecture
    }
    return true;
  }
}
