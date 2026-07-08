import '../entities/report_history_model.dart';

class StorageOptimizer {
  const StorageOptimizer();

  List<ReportHistoryEntry> filterOlderThan(List<ReportHistoryEntry> list, int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return list.where((e) => e.createdAt.isBefore(cutoffDate)).toList();
  }

  List<ReportHistoryEntry> filterMissing(List<ReportHistoryEntry> list, bool Function(String) existsCheck) {
    return list.where((e) => !existsCheck(e.filePath)).toList();
  }
}
