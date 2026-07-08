import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/data/datasources/repository_cache.dart';

import 'package:fintrack/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:fintrack/features/budget/domain/entities/budget_entity.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fintrack/features/budget/domain/repositories/budget_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  List<TransactionEntity> transactions = [];
  final _controller = StreamController<List<TransactionEntity>>.broadcast();

  @override
  Future<List<TransactionEntity>> getTransactions() async => transactions;

  @override
  Stream<List<TransactionEntity>> watchTransactions() => _controller.stream;

  void triggerUpdate(List<TransactionEntity> list) {
    transactions = list;
    _controller.add(list);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockBudgetRepository implements BudgetRepository {
  List<BudgetEntity> budgets = [];
  final _controller = StreamController<List<BudgetEntity>>.broadcast();

  @override
  Future<List<BudgetEntity>> getActiveBudgets() async => budgets;

  @override
  Stream<List<BudgetEntity>> watchBudgets() => _controller.stream;

  void triggerUpdate(List<BudgetEntity> list) {
    budgets = list;
    _controller.add(list);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RepositoryCache Tests', () {
    test('stores and retrieves cached values correctly', () {
      final cache = RepositoryCache();
      expect(cache.get<String>('key1'), isNull);
      expect(cache.cacheMisses, 1);

      cache.put('key1', 'cached_value');
      expect(cache.get<String>('key1'), 'cached_value');
      expect(cache.cacheHits, 1);

      cache.clear();
      expect(cache.get<String>('key1'), isNull);
    });
  });

  group('AnalyticsRepository Cache Integration Tests', () {
    late MockTransactionRepository mockTxRepo;
    late MockBudgetRepository mockBudgetRepo;
    late AnalyticsRepositoryImpl repository;

    setUp(() {
      mockTxRepo = MockTransactionRepository();
      mockBudgetRepo = MockBudgetRepository();
      repository = AnalyticsRepositoryImpl(mockTxRepo, mockBudgetRepo);
    });

    test('invalidates cache reactively when transactions update', () async {
      mockTxRepo.triggerUpdate([
        TransactionEntity(
          id: '1',
          amount: 5000.0,
          type: 'income',
          category: 'Salary',
          title: 'Pay',
          date: DateTime.now(),
        )
      ]);
      mockBudgetRepo.triggerUpdate([]);

      final anchor = DateTime.now();

      // First run: cache miss, aggregates report
      final report1 = await repository.getMonthlyReport(anchor);
      expect(report1.summary.income, 5000.0);

      // Second run: cache hit
      final report2 = await repository.getMonthlyReport(anchor);
      expect(report2.summary.income, 5000.0);

      // Trigger transaction update: should invalidate/clear cache
      mockTxRepo.triggerUpdate([
        TransactionEntity(
          id: '1',
          amount: 6000.0,
          type: 'income',
          category: 'Salary',
          title: 'Bonus Pay',
          date: DateTime.now(),
        )
      ]);

      // Delay to ensure stream listener triggers clear
      await Future.delayed(const Duration(milliseconds: 10));

      final report3 = await repository.getMonthlyReport(anchor);
      expect(report3.summary.income, 6000.0); // Verifies fresh calculation ran
    });
  });
}
