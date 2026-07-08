import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/reports/domain/entities/report_history_model.dart';
import 'package:fintrack/features/reports/data/repositories/report_history_repository_impl.dart';

void main() {
  group('ReportHistoryRepository Tests', () {
    late ReportHistoryRepositoryImpl repository;

    setUp(() {
      repository = ReportHistoryRepositoryImpl();
    });

    test('saves and retrieves report metadata history', () async {
      final entry = ReportHistoryEntry(
        id: '1',
        reportName: 'July Summary',
        reportType: 'Financial Summary',
        exportFormat: 'PDF',
        filePath: '/storage/july.pdf',
        fileSize: 1048576, // 1 MB
        pageCount: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'Available',
        template: 'Standard',
        filtersApplied: {},
        ownerId: 'user-1',
        syncStatus: 'local',
      );

      await repository.saveReportHistory(entry);
      final history = await repository.getReportHistory();

      expect(history.length, 1);
      expect(history.first.reportName, 'July Summary');
      expect(history.first.fileSize, 1048576);
    });

    test('renames an existing report correctly', () async {
      final entry = ReportHistoryEntry(
        id: '1',
        reportName: 'July Summary',
        reportType: 'Financial Summary',
        exportFormat: 'PDF',
        filePath: '/storage/july.pdf',
        fileSize: 1048576,
        pageCount: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'Available',
        template: 'Standard',
        filtersApplied: {},
        ownerId: 'user-1',
        syncStatus: 'local',
      );

      await repository.saveReportHistory(entry);
      await repository.renameReport('1', 'July Final Report');
      final history = await repository.getReportHistory();

      expect(history.first.reportName, 'July Final Report');
    });

    test('searches report entries correctly by name or format', () async {
      final entry1 = ReportHistoryEntry(
        id: '1',
        reportName: 'Income CSV',
        reportType: 'Income',
        exportFormat: 'CSV',
        filePath: '/storage/income.csv',
        fileSize: 2048,
        pageCount: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'Available',
        template: 'Standard',
        filtersApplied: {},
        ownerId: 'user-1',
        syncStatus: 'local',
      );

      final entry2 = ReportHistoryEntry(
        id: '2',
        reportName: 'Expense PDF',
        reportType: 'Expense',
        exportFormat: 'PDF',
        filePath: '/storage/expense.pdf',
        fileSize: 524288,
        pageCount: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'Available',
        template: 'Standard',
        filtersApplied: {},
        ownerId: 'user-1',
        syncStatus: 'local',
      );

      await repository.saveReportHistory(entry1);
      await repository.saveReportHistory(entry2);

      final csvSearch = await repository.searchReports('csv');
      expect(csvSearch.length, 1);
      expect(csvSearch.first.reportName, 'Income CSV');

      final expenseSearch = await repository.searchReports('Expense');
      expect(expenseSearch.length, 1);
      expect(expenseSearch.first.reportName, 'Expense PDF');
    });

    test('calculates correct storage statistics totals', () async {
      final entry = ReportHistoryEntry(
        id: '1',
        reportName: 'June Analytics',
        reportType: 'Analytics',
        exportFormat: 'Excel',
        filePath: '/storage/june.xlsx',
        fileSize: 2097152, // 2 MB
        pageCount: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'Available',
        template: 'Standard',
        filtersApplied: {},
        ownerId: 'user-1',
        syncStatus: 'local',
      );

      await repository.saveReportHistory(entry);
      final stats = await repository.calculateStorageUsage();

      expect(stats['totalCount'], 1);
      expect(stats['totalSize'], 2.0); // 2 MB
      expect(stats['averageSize'], 2048.0); // 2048 KB
    });
  });
}
