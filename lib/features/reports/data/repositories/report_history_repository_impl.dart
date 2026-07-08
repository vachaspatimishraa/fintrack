import 'dart:async';
import '../../domain/entities/report_history_model.dart';
import '../../domain/repositories/report_history_repository.dart';

class ReportHistoryRepositoryImpl implements ReportHistoryRepository {
  final List<ReportHistoryEntry> _history = [];
  final StreamController<List<ReportHistoryEntry>> _controller = StreamController<List<ReportHistoryEntry>>.broadcast();

  ReportHistoryRepositoryImpl() {
    _controller.add(List.unmodifiable(_history));
  }

  @override
  Future<void> saveReportHistory(ReportHistoryEntry entry) async {
    _history.add(entry);
    _controller.add(List.unmodifiable(_history));
  }

  @override
  Future<List<ReportHistoryEntry>> getReportHistory() async {
    return List.unmodifiable(_history);
  }

  @override
  Stream<List<ReportHistoryEntry>> watchReportHistory() {
    return _controller.stream;
  }

  @override
  Future<void> renameReport(String id, String newName) async {
    final index = _history.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _history[index] = _history[index].copyWith(
        reportName: newName,
        updatedAt: DateTime.now(),
      );
      _controller.add(List.unmodifiable(_history));
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    _history.removeWhere((e) => e.id == id);
    _controller.add(List.unmodifiable(_history));
  }

  @override
  Future<void> deleteAllReports() async {
    _history.clear();
    _controller.add(List.unmodifiable(_history));
  }

  @override
  Future<List<ReportHistoryEntry>> searchReports(String query) async {
    if (query.isEmpty) return List.unmodifiable(_history);
    final term = query.toLowerCase();
    return _history.where((e) {
      return e.reportName.toLowerCase().contains(term) ||
          e.reportType.toLowerCase().contains(term) ||
          e.exportFormat.toLowerCase().contains(term);
    }).toList();
  }

  @override
  Future<List<ReportHistoryEntry>> filterReports({
    String? format,
    String? type,
    String? status,
    DateTime? startDate,
  }) async {
    return _history.where((e) {
      if (format != null && e.exportFormat.toLowerCase() != format.toLowerCase()) return false;
      if (type != null && e.reportType.toLowerCase() != type.toLowerCase()) return false;
      if (status != null && e.status.toLowerCase() != status.toLowerCase()) return false;
      if (startDate != null && e.createdAt.isBefore(startDate)) return false;
      return true;
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> calculateStorageUsage() async {
    if (_history.isEmpty) {
      return {
        'totalCount': 0,
        'totalSize': 0.0, // in megabytes
        'averageSize': 0.0, // in kilobytes
      };
    }

    final totalSize = _history.fold<int>(0, (sum, e) => sum + e.fileSize);
    final totalCount = _history.length;

    return {
      'totalCount': totalCount,
      'totalSize': totalSize / (1024 * 1024), // MB
      'averageSize': (totalSize / totalCount) / 1024, // KB
    };
  }

  @override
  Future<void> syncHistory() async {
    // Optionally trigger cloud synchronization
  }
}
