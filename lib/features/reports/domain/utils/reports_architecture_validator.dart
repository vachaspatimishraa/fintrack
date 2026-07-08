class ReportsArchitectureValidator {
  const ReportsArchitectureValidator();

  bool validateImports(String fileContent) {
    if (fileContent.contains("import 'package:flutter/material.dart'") &&
        (fileContent.contains("class ReportHistoryRepositoryImpl") ||
            fileContent.contains("class PDFReportEngine") ||
            fileContent.contains("class ExcelExportEngine"))) {
      return false; // Violates clean architecture rules
    }
    return true;
  }

  bool validateSingleSourceOfTruth(String widgetContent) {
    if (widgetContent.contains("import 'package:isar/isar.dart'") ||
        widgetContent.contains("import 'package:supabase_flutter/supabase_flutter.dart'")) {
      if (widgetContent.contains("class ReportHistoryScreen") ||
          widgetContent.contains("class ReportPreviewScreen")) {
        return false; // Direct db access bypasses repository
      }
    }
    return true;
  }
}
