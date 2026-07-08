import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/entities/custom_report_data.dart';
import 'package:fintrack/features/analytics/domain/utils/filter_engine.dart';
import 'package:fintrack/features/analytics/domain/utils/grouping_engine.dart';
import 'package:fintrack/features/analytics/domain/utils/statistics_engine.dart';
import 'package:fintrack/features/analytics/domain/utils/custom_report_engine.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('FilterEngine Tests', () {
    final transactions = [
      _tx(id: '1', amount: 5000, type: 'income', date: DateTime(2026, 7, 5), category: 'Salary', title: 'Paycheck'),
      _tx(id: '2', amount: 2000, type: 'expense', date: DateTime(2026, 7, 10), category: 'Food', title: 'Resto Dinner'),
      _tx(id: '3', amount: 1500, type: 'expense', date: DateTime(2026, 7, 20), category: 'Shopping', title: 'Shirts'),
      _tx(id: '4', amount: 300, type: 'expense', date: DateTime(2026, 6, 25), category: 'Food', title: 'Groceries'),
    ];

    test('filters by category', () {
      final filter = const CustomReportFilter(selectedCategories: ['Food']);
      final result = FilterEngine.filter(transactions: transactions, filter: filter);
      expect(result.length, 2);
      expect(result.any((t) => t.category == 'Food'), true);
    });

    test('filters by type', () {
      final filter = const CustomReportFilter(selectedTypes: ['income']);
      final result = FilterEngine.filter(transactions: transactions, filter: filter);
      expect(result.length, 1);
      expect(result.first.type, 'income');
    });

    test('filters by amount range', () {
      final filter = const CustomReportFilter(minAmount: 1000, maxAmount: 3000);
      final result = FilterEngine.filter(transactions: transactions, filter: filter);
      expect(result.length, 2); // 2000 and 1500
    });

    test('filters by search query', () {
      final filter = const CustomReportFilter(searchQuery: 'dinner');
      final result = FilterEngine.filter(transactions: transactions, filter: filter);
      expect(result.length, 1);
      expect(result.first.title, 'Resto Dinner');
    });
  });

  group('GroupingEngine Tests', () {
    final transactions = [
      _tx(id: '1', amount: 5000, type: 'income', date: DateTime(2026, 7, 5), category: 'Salary'),
      _tx(id: '2', amount: 2000, type: 'expense', date: DateTime(2026, 7, 10), category: 'Food'),
      _tx(id: '3', amount: 1500, type: 'expense', date: DateTime(2026, 7, 20), category: 'Shopping'),
      _tx(id: '4', amount: 300, type: 'expense', date: DateTime(2026, 7, 25), category: 'Food'),
    ];

    test('groups by category', () {
      final result = GroupingEngine.group(transactions: transactions, groupBy: 'category');
      expect(result.length, 3); // Salary, Food, Shopping
      final foodGroup = result.firstWhere((g) => g.name == 'Food');
      expect(foodGroup.expense, 2300.0);
      expect(foodGroup.transactionCount, 2);
    });

    test('groups by month', () {
      final result = GroupingEngine.group(transactions: transactions, groupBy: 'month');
      expect(result.length, 1);
      expect(result.first.name, 'July 2026');
    });
  });

  group('StatisticsEngine Tests', () {
    test('calculates correct statistics totals', () {
      final transactions = [
        _tx(id: '1', amount: 10000, type: 'income', date: DateTime(2026, 7, 5)),
        _tx(id: '2', amount: 4000, type: 'expense', date: DateTime(2026, 7, 10)),
      ];

      final stats = StatisticsEngine.calculate(transactions);
      expect(stats.income, 10000.0);
      expect(stats.expense, 4000.0);
      expect(stats.savings, 6000.0);
      expect(stats.cashFlow, 6000.0);
      expect(stats.averageTransaction, 7000.0);
      expect(stats.largestTransaction, 10000.0);
      expect(stats.transactionCount, 2);
    });
  });

  group('CustomReportEngine Tests', () {
    test('generates dataset completely', () {
      final transactions = [
        _tx(id: '1', amount: 10000, type: 'income', date: DateTime(2026, 7, 5), category: 'Salary'),
        _tx(id: '2', amount: 4000, type: 'expense', date: DateTime(2026, 7, 10), category: 'Food'),
        _tx(id: '3', amount: 1000, type: 'expense', date: DateTime(2026, 7, 20), category: 'Shopping'),
      ];

      final filter = const CustomReportFilter(selectedCategories: ['Food', 'Shopping']);

      final dataset = CustomReportEngine.generate(
        transactions: transactions,
        filter: filter,
        groupBy: 'category',
        sortBy: 'highestAmount',
      );

      expect(dataset.isEmpty, false);
      expect(dataset.transactions.length, 2);
      expect(dataset.stats.expense, 5000.0);
      expect(dataset.groups.length, 2);
      // Sorted highestAmount: Food (4000) then Shopping (1000)
      expect(dataset.transactions.first.category, 'Food');
    });
  });
}

TransactionEntity _tx({
  required String id,
  required double amount,
  required String type,
  required DateTime date,
  String category = 'Others',
  String title = 'Sample',
}) {
  return TransactionEntity(
    id: id,
    type: type,
    amount: amount,
    category: category,
    title: title,
    date: date,
  );
}
