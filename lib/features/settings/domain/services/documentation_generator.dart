/// Utility to generate documentation summaries for the Settings Module.
class DocumentationGenerator {
  /// Generates a manifest of the module's documented public interfaces.
  static String getModuleSummary() {
    return '''
    FinTrack Settings Module v1.0
    ----------------------------
    Core Repositories: SettingsRepository, BackupRepository, DeveloperRepository
    Architecture: MVC with Riverpod & Repository Pattern
    Standards Compliance: WCAG 2.2 AA, Material 3
    ''';
  }
}
