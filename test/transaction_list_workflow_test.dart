import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_query_filter.dart';
import 'package:fintrack/features/transactions/presentation/widgets/quick_filter_chips.dart';

void main() {
  group('Transaction List & Filters Unit and Widget Tests', () {

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
