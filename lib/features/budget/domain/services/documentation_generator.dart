/// Internal utility to generate module documentation summaries.
class DocumentationGenerator {
  /// Generates a manifest of the module's documented components.
  static String generateSummary() {
    return '''
    FinTrack Budget Module v1.0
    --------------------------
    Core Repositories: BudgetRepository, BudgetAlertRepository, RecommendationRepository
    Business Engines: BudgetAlertEngine, BudgetRecommendationEngine, BudgetDashboardEngine
    UI Framework: MVC with Riverpod & Material 3
    Persistence: Offline-first with Isar
    ''';
  }
}
