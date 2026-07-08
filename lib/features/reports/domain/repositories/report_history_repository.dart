import '../entities/report_history_model.dart';

abstract class ReportHistoryRepository {
  Future<void> saveReportHistory(ReportHistoryEntry entry);
  Future<List<ReportHistoryEntry>> getReportHistory();
  Stream<List<ReportHistoryEntry>> watchReportHistory();
  Future<void> renameReport(String id, String newName);
  Future<void> deleteReport(String id);
  Future<void> deleteAllReports();
  Future<List<ReportHistoryEntry>> searchReports(String query);
  Future<List<ReportHistoryEntry>> filterReports({
    String? format,
    String? type,
    String? status,
    DateTime? startDate,
  });
  Future<Map<String, dynamic>> calculateStorageUsage();
  Future<void> syncHistory();
}
