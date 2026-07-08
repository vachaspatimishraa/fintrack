import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/yearly_report_data.dart';
import '../../domain/repositories/analytics_repository.dart';

class YearlyReportController {
  final AnalyticsRepository _repository;
  final Ref ref;

  YearlyReportController(this._repository, this.ref);

  DateTime previousYear(DateTime yearAnchor) {
    return DateTime(yearAnchor.year - 1, 1, 1);
  }

  DateTime nextYear(DateTime yearAnchor) {
    return DateTime(yearAnchor.year + 1, 1, 1);
  }

  DateTime currentYear() => DateTime.now();

  String yearLabel(DateTime yearAnchor) {
    return '${yearAnchor.year}';
  }

  List<String> insights(YearlyReport report) {
    return report.insights;
  }

  AnalyticsRepository get repository => _repository;

  // Export handlers
  Future<bool> exportPDF(YearlyReport report) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> exportExcel(YearlyReport report) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> exportCSV(YearlyReport report) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> shareReport(YearlyReport report) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> printReport(YearlyReport report) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
