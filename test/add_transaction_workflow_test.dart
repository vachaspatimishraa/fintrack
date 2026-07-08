import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import 'package:fintrack/features/accounts/providers/account_provider.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';
import 'package:fintrack/features/settings/providers/settings_provider.dart';

void main() {
  testWidgets('AddEditTransactionScreen displays properly when accounts exist', (WidgetTester tester) async {
    final account = AccountModel()
      ..uuid = 'acc-111'
      ..name = 'Test Wallet'
      ..balance = 1000.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountsStreamProvider.overrideWith((ref) => Stream.value([account])),
          settingsProvider.overrideWith((ref) => Stream.value(SettingsEntity())),
        ],
        child: const MaterialApp(
          home: AddEditTransactionScreen(),
        ),
      ),
    );

    // Initial load frame
    await tester.pump();

    // Verify segments exist
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Save Transaction'), findsOneWidget);
  });
}
