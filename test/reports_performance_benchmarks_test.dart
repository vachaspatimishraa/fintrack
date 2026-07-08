import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/reports/domain/utils/report_performance_service.dart';
import 'package:fintrack/features/reports/domain/utils/validation_optimizer.dart';
import 'package:fintrack/features/reports/domain/utils/storage_optimizer.dart';
import 'package:fintrack/features/reports/domain/entities/report_history_model.dart';

void main() {
  group('ReportPerformanceService Tests', () {
    test('tracks elapsed durations in milliseconds', () async {
      final service = ReportPerformanceService();
      service.start('pdf-generation');
      await Future.delayed(const Duration(milliseconds: 30));
      final ms = service.stop('pdf-generation');

      expect(ms, greaterThanOrEqualTo(25));
      expect(service.getLogs().first.contains('pdf-generation'), true);
    });
  });

  group('ValidationOptimizer Tests', () {
    const val = ValidationOptimizer();

    test('validates file formats correctly', () {
      expect(val.validateFilePath('/reports/july.pdf'), true);
      expect(val.validateFilePath('/reports/july.xlsx'), true);
      expect(val.validateFilePath('/reports/july.txt'), false);
    });

    test('validates file sizes correctly', () {
      expect(val.validateFileSize(1024), true); // 1 KB
      expect(val.validateFileSize(60 * 1024 * 1024), false); // 60 MB exceeds 50 MB limit
    });
  });

  group('StorageOptimizer Tests', () {
    const opt = StorageOptimizer();

    test('filters report entries older than X days', () {
      final list = [
        _entry('1', DateTime.now().subtract(const Duration(days: 40))),
        _entry('2', DateTime.now().subtract(const Duration(days: 10))),
      ];

      final olderThan30 = opt.filterOlderThan(list, 30);
      expect(olderThan30.length, 1);
      expect(olderThan30.first.id, '1');
    });
  });
}

ReportHistoryEntry _entry(String id, DateTime date) {
  return ReportHistoryEntry(
    id: id,
    reportName: 'Report $id',
    reportType: 'Financial Summary',
    exportFormat: 'PDF',
    filePath: '/storage/report_$id.pdf',
    fileSize: 1024,
    pageCount: 1,
    createdAt: date,
    updatedAt: date,
    status: 'Available',
    template: 'Standard',
    filtersApplied: {},
    ownerId: 'user-1',
    syncStatus: 'local',
  );
}
