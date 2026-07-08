import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/analytics_performance_service.dart';
import 'package:fintrack/features/analytics/domain/utils/lazy_loading_manager.dart';
import 'package:fintrack/features/analytics/domain/utils/aggregation_optimizer.dart';
import 'package:fintrack/features/analytics/domain/entities/monthly_report_data.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('AnalyticsPerformanceService Benchmarks', () {
    test('measures elapsed execution duration in milliseconds', () async {
      final service = AnalyticsPerformanceService();
      service.start('test-duration');
      await Future.delayed(const Duration(milliseconds: 50));
      final ms = service.stop('test-duration');

      expect(ms, greaterThanOrEqualTo(40));
      expect(service.getLogs().first.contains('test-duration'), true);
    });
  });

  group('LazyLoadingManager Benchmarks', () {
    test('paginates transaction items efficiently in chunks of 50', () {
      final list = List.generate(
        125,
        (i) => TransactionEntity(
          id: '$i',
          amount: 100.0,
          type: 'expense',
          category: 'Shopping',
          title: 'Item $i',
          date: DateTime.now(),
        ),
      );

      final manager = LazyLoadingManager<TransactionEntity>(list, pageSize: 50);

      // Page 1
      final p1 = manager.getNextPage();
      expect(p1.length, 50);
      expect(manager.hasMore, true);

      // Load Page 2
      manager.loadMore();
      final p2 = manager.getNextPage();
      expect(p2.length, 100);

      // Load Page 3
      manager.loadMore();
      final p3 = manager.getNextPage();
      expect(p3.length, 125);
      expect(manager.hasMore, false);
    });
  });

  group('AggregationOptimizer Benchmarks', () {
    test('performs incremental updates in less than 1ms', () {
      const summary = MonthlySummary(income: 10000.0, expense: 4000.0, savings: 6000.0, cashFlow: 6000.0);
      final newTx = TransactionEntity(
        id: '100',
        amount: 2000.0,
        type: 'income',
        category: 'Salary',
        title: 'Freelance pay',
        date: DateTime.now(),
      );

      // Warm up VM to compile JIT path
      AggregationOptimizer.incrementalUpdate(
        currentSummary: summary,
        updatedTransaction: newTx,
        action: 'create',
      );

      final stopwatch = Stopwatch()..start();
      final updated = AggregationOptimizer.incrementalUpdate(
        currentSummary: summary,
        updatedTransaction: newTx,
        action: 'create',
      );
      stopwatch.stop();

      expect(updated.income, 12000.0);
      expect(updated.savings, 8000.0);
      expect(stopwatch.elapsedMicroseconds, lessThan(1000)); // Should run in microseconds (<1ms)
    });
  });
}
