import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/reports/domain/entities/report_history_model.dart';
import 'package:fintrack/features/reports/domain/repositories/report_api_contracts.dart';

class MockReportRepository implements ReportRepository {
  final List<ReportHistoryEntry> _list = [];

  @override
  Future<void> generateReport(ReportRequest request) async {
    _list.add(ReportHistoryEntry(
      id: '1',
      reportName: request.reportName,
      reportType: request.reportType,
      exportFormat: request.exportFormat,
      filePath: '/storage/report.pdf',
      fileSize: 1024,
      pageCount: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'Available',
      template: request.templateId,
      filtersApplied: request.filters,
      ownerId: 'user-1',
      syncStatus: 'local',
    ));
  }

  @override
  Future<List<ReportHistoryEntry>> getHistory() async => _list;

  @override
  Stream<List<ReportHistoryEntry>> watchHistory() => Stream.value(_list);

  @override
  Future<void> deleteReport(String reportId) async {
    _list.removeWhere((e) => e.id == reportId);
  }

  @override
  Future<void> renameReport(String reportId, String name) async {}
}

class MockExportEngine implements ExportEngine {
  @override
  Future<File> export(ReportRequest request) async {
    return File('/storage/mock_report.pdf');
  }

  @override
  Future<bool> validate(File report) async => true;
}

void main() {
  group('Reports Contracts Compliance Tests', () {
    test('satisfies abstract signatures for ReportRepository and ExportEngine', () async {
      final repo = MockReportRepository();
      final engine = MockExportEngine();

      await repo.generateReport(
        const ReportRequest(
          reportName: 'August Report',
          reportType: 'Summary',
          exportFormat: 'PDF',
          filters: {},
          templateId: 'Standard',
        ),
      );

      final history = await repo.getHistory();
      expect(history.length, 1);
      expect(history.first.reportName, 'August Report');

      final file = await engine.export(
        const ReportRequest(
          reportName: 'August Report',
          reportType: 'Summary',
          exportFormat: 'PDF',
          filters: {},
          templateId: 'Standard',
        ),
      );
      expect(file.path, '/storage/mock_report.pdf');
    });
  });
}
