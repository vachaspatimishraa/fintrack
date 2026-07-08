class ReportsPerformanceValidator {
  const ReportsPerformanceValidator();

  bool validateMetrics({
    required int reportGenerationMs,
    required int previewGenerationMs,
    required int pdfExportMs,
    required int excelExportMs,
    required int csvExportMs,
  }) {
    if (reportGenerationMs > 500) return false;
    if (previewGenerationMs > 500) return false;
    if (pdfExportMs > 2000) return false;
    if (excelExportMs > 1000) return false;
    if (csvExportMs > 500) return false;
    return true;
  }
}
