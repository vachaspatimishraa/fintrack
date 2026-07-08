class ArchitectureValidationService {
  const ArchitectureValidationService();

  bool validateImports(String fileContent) {
    // Analytics repositories or engines must not import Material or widgets
    if (fileContent.contains("import 'package:flutter/material.dart'") &&
        (fileContent.contains("class AnalyticsRepositoryImpl") ||
            fileContent.contains("class MonthlyAggregator") ||
            fileContent.contains("class YearlyAggregator"))) {
      return false; // Violates clean architecture separation
    }
    return true;
  }

  bool validateSingleSourceOfTruth(String widgetContent) {
    // Screen/widget must not access Isar or Supabase directly
    if (widgetContent.contains("import 'package:isar/isar.dart'") ||
        widgetContent.contains("import 'package:supabase_flutter/supabase_flutter.dart'")) {
      if (widgetContent.contains("class SpendingTrendScreen") ||
          widgetContent.contains("class YearlyReportScreen") ||
          widgetContent.contains("class CustomReportScreen") ||
          widgetContent.contains("class FinancialHealthScreen") ||
          widgetContent.contains("class AIInsightsScreen")) {
        return false; // Direct access from UI bypasses repository
      }
    }
    return true;
  }
}
