import 'dart:io';
import '../entities/report_history_model.dart';

class ReportRequest {
  final String reportName;
  final String reportType;
  final String exportFormat;
  final Map<String, dynamic> filters;
  final String templateId;

  const ReportRequest({
    required this.reportName,
    required this.reportType,
    required this.exportFormat,
    required this.filters,
    required this.templateId,
  });
}

class PdfReportRequest extends ReportRequest {
  const PdfReportRequest({
    required super.reportName,
    required super.reportType,
    required super.filters,
    required super.templateId,
  }) : super(exportFormat: 'PDF');
}

class ExcelReportRequest extends ReportRequest {
  const ExcelReportRequest({
    required super.reportName,
    required super.reportType,
    required super.filters,
    required super.templateId,
  }) : super(exportFormat: 'Excel');
}

class CsvReportRequest extends ReportRequest {
  const CsvReportRequest({
    required super.reportName,
    required super.reportType,
    required super.filters,
    required super.templateId,
  }) : super(exportFormat: 'CSV');
}

abstract class ReportRepository {
  Future<void> generateReport(ReportRequest request);
  Future<List<ReportHistoryEntry>> getHistory();
  Stream<List<ReportHistoryEntry>> watchHistory();
  Future<void> deleteReport(String reportId);
  Future<void> renameReport(String reportId, String name);
}

abstract class ReportLocalDatasource {
  Future<void> saveMetadata(ReportHistoryEntry report);
  Future<List<ReportHistoryEntry>> loadHistory();
  Stream<List<ReportHistoryEntry>> watchHistory();
  Future<void> delete(String reportId);
}

abstract class ReportRemoteDatasource {
  Future<void> uploadMetadata(ReportHistoryEntry report);
  Future<void> synchronize();
  Future<List<ReportHistoryEntry>> downloadHistory();
}

abstract class ExportEngine {
  Future<File> export(ReportRequest request);
  Future<bool> validate(File report);
}

abstract class TemplateEngine {
  Future<String> render(ReportRequest request);
}
