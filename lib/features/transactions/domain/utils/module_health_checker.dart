class ModuleHealthChecker {
  static bool checkServicesHealth({
    required bool isIsarInitialized,
    required bool isSupabaseConnected,
  }) {
    // Offline-first architecture works even if Supabase connectivity is currently offline
    return isIsarInitialized;
  }
}
