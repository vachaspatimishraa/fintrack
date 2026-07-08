import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/transactions/domain/utils/recurring_transaction_engine.dart';
import 'package:fintrack/features/transactions/domain/utils/transfer_service.dart';
import 'package:fintrack/features/transactions/domain/utils/split_transaction_service.dart';
import 'package:fintrack/features/transactions/domain/utils/smart_suggestion_engine.dart';
import 'package:fintrack/features/transactions/domain/utils/import_service.dart';

void main() {
  group('Advanced Transaction Engine & Scaling Tests', () {
    test('RecurringTransactionEngine calculates next execution dates', () {
      final baseDate = DateTime(2026, 7, 1);
      
      final nextDaily = RecurringTransactionEngine.calculateNextExecution(baseDate, 'daily');
      expect(nextDaily, equals(DateTime(2026, 7, 2)));

      final nextWeekly = RecurringTransactionEngine.calculateNextExecution(baseDate, 'weekly');
      expect(nextWeekly, equals(DateTime(2026, 7, 8)));

      final nextMonthly = RecurringTransactionEngine.calculateNextExecution(baseDate, 'monthly');
      expect(nextMonthly, equals(DateTime(2026, 8, 1)));
    });

    test('TransferService generates a pair of linked transactions', () {
      final pair = TransferService.createTransfer(
        fromAccountId: 'acc-source',
        toAccountId: 'acc-dest',
        amount: 500.0,
        date: DateTime.now(),
        currency: 'USD',
      );

      expect(pair.length, equals(2));
      expect(pair[0].type, equals('expense'));
      expect(pair[1].type, equals('income'));
      expect(pair[0].amount, equals(500.0));
      expect(pair[1].amount, equals(500.0));
    });

    test('SplitTransactionService correctly splits transactions or throws', () {
      final parent = TransactionEntity(
        uuid: 'parent-1',
        accountId: 'acc-1',
        type: 'expense',
        categoryId: 'Misc',
        category: 'Misc',
        amount: 100.0,
        title: 'Bill',
        description: 'Split bill',
        currency: 'USD',
        paymentMethod: 'Cash',
        tags: const [],
        isDeleted: false,
        isSynced: false,
        isRecurring: false,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncVersion: 1,
      );

      final splits = [
        const SplitLine(categoryId: 'Food', category: 'Food', amount: 40.0),
        const SplitLine(categoryId: 'Travel', category: 'Travel', amount: 60.0),
      ];

      final children = SplitTransactionService.split(parent, splits);
      expect(children.length, equals(2));
      expect(children[0].amount, equals(40.0));
      expect(children[1].amount, equals(60.0));

      final invalidSplits = [
        const SplitLine(categoryId: 'Food', category: 'Food', amount: 40.0),
      ];
      expect(() => SplitTransactionService.split(parent, invalidSplits), throwsArgumentError);
    });

    test('SmartSuggestionEngine suggests category and tags from merchant', () {
      expect(SmartSuggestionEngine.suggestCategory('Swiggy Lunch'), equals('Food'));
      expect(SmartSuggestionEngine.suggestCategory('Netflix Membership'), equals('Subscription'));
      expect(SmartSuggestionEngine.suggestTags('Uber Ride'), contains('uber'));
    });

    test('ImportService parses CSV values correctly', () {
      const csv = 'Date,Amount,Title,Category,PaymentMethod\n2026-07-01,-15.50,Uber,Travel,Credit Card';
      final list = ImportService.parseCsv(csv);
      expect(list.length, equals(1));
      expect(list[0].amount, equals(15.50));
      expect(list[0].type, equals('expense'));
      expect(list[0].title, equals('Uber'));
    });
  });
}
