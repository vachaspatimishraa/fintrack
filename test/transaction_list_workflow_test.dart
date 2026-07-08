import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_query_filter.dart';
import 'package:fintrack/features/transactions/presentation/widgets/quick_filter_chips.dart';

void main() {
  group('Transaction List & Filters Unit and Widget Tests', () {
    late TransactionEntity tx1;
    late TransactionEntity tx2;

    setUp(() {
      tx1 = TransactionEntity(
        uuid: 'tx-101',
        accountId: 'acc-1',
        type: 'income',
        categoryId: 'Salary',
        category: 'Salary',
        amount: 5000.0,
        title: 'Monthly Pay',
        description: 'Salary',
        currency: 'USD',
        paymentMethod: 'Bank Transfer',
        tags: const ['work'],
        isDeleted: false,
        isSynced: true,
        isRecurring: false,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncVersion: 1,
      );

      tx2 = TransactionEntity(
        uuid: 'tx-102',
        accountId: 'acc-1',
        type: 'expense',
        categoryId: 'Food',
        category: 'Food',
        amount: 20.0,
        title: 'Tacos',
        description: 'Taco Bell',
        currency: 'USD',
        paymentMethod: 'Cash',
        tags: const ['food'],
        isDeleted: false,
        isSynced: true,
        isRecurring: false,
        date: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncVersion: 1,
      );
    });

    test('TransactionQueryFilter sets initial values correctly', () {
      const filter = TransactionQueryFilter();
      expect(filter.query, isEmpty);
      expect(filter.sortBy, equals('newest'));
      expect(filter.isDeleted, isFalse);
    });

    test('TransactionQueryFilter copyWith copies and overrides fields', () {
      const filter = TransactionQueryFilter();
      final updated = filter.copyWith(query: 'work', type: 'income', sortBy: 'highest_amount');

      expect(updated.query, equals('work'));
      expect(updated.type, equals('income'));
      expect(updated.sortBy, equals('highest_amount'));
    });

    testWidgets('QuickFilterChips renders correct segments', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: QuickFilterChips(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
    });
  });
}
