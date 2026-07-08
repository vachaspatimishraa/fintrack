class OfflineComplianceChecker {
  const OfflineComplianceChecker();

  bool isOfflineCompliant(String repositoryFileContent) {
    // Analytics repository must never perform http, client connection requests or fetches directly
    if (repositoryFileContent.contains('http.get') ||
        repositoryFileContent.contains('client.from') ||
        repositoryFileContent.contains('fetchUrl')) {
      return false; // Direct cloud queries violate offline-first architecture
    }
    return true;
  }
}
