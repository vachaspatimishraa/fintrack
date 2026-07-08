/// Internal utility to generate module documentation summaries.
class DocumentationGenerator {
  /// Generates a manifest of the module's documented components.
  static String generateGoalsSummary() {
    return '''
    FinTrack Goals Module v1.0
    -------------------------
    Core Repository: GoalRepository
    Core Engine: GoalEngine (Milestones, Contributions)
    State Management: Riverpod (AsyncNotifier, StreamProvider)
    Database: Isar (GoalModel, ContributionModel, MilestoneModel)
    Performance: Isolate processing for large datasets.
    ''';
  }
}
