import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import 'package:fintrack/features/accounts/providers/account_provider.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';
import 'package:fintrack/features/settings/providers/settings_provider.dart';

import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_query_filter.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fintrack/features/transactions/providers/transaction_provider.dart';
import 'package:fintrack/features/transactions/presentation/controllers/transaction_controller.dart';

class FakeTransactionRepo implements TransactionRepository {
  final List<TransactionEntity> saved = [];

  @override
  Future<void> saveTransaction(TransactionEntity transaction) async {
    saved.add(transaction);
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() => Stream.value([]);
  @override
  Stream<TransactionEntity?> watchTransaction(String uuid) => Stream.value(null);
  @override
  Stream<List<TransactionEntity>> watchRecentTransactions(int limit) => Stream.value([]);
  @override
  Stream<List<TransactionEntity>> watchTransactionsByCategory(String category) => Stream.value([]);
  @override
  Stream<List<TransactionEntity>> watchTransactionsByDate(DateTime date) => Stream.value([]);
  @override
  Stream<List<TransactionEntity>> watchDeletedTransactions() => Stream.value([]);
  @override
  Stream<List<TransactionEntity>> watchPendingSyncTransactions() => Stream.value([]);
  @override
  Future<List<TransactionEntity>> getTransactions() async => [];
  @override
  Future<TransactionEntity?> getTransactionByUuid(String uuid) async => null;
  @override
  Future<void> deleteTransaction(String uuid) async {}
  @override
  Future<void> restoreTransaction(String uuid) async {}
  @override
  Future<List<TransactionEntity>> getDeletedTransactions() async => [];
  @override
  Future<List<TransactionEntity>> getTransactionsPaginated({
    required int limit,
    required int offset,
    required TransactionQueryFilter queryFilter,
  }) async => [];
}

class TestTransactionController extends TransactionController {
  final FakeTransactionRepo repo;
  TestTransactionController(super.ref, this.repo);

  @override
  Future<void> saveTransaction(TransactionEntity transaction) async {
    await repo.saveTransaction(transaction);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
  });

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

  testWidgets('AddEditTransactionScreen resets form to blank when Add Another is tapped after edit', (WidgetTester tester) async {
    final account = AccountModel()
      ..uuid = 'acc-111'
      ..name = 'Test Wallet'
      ..balance = 1000.0;

    final fakeRepo = FakeTransactionRepo();
    final initialTx = TransactionEntity(
      uuid: 'tx-existing',
      type: 'expense',
      category: 'Food',
      amount: 45.0,
      accountId: 'acc-111',
      title: 'Lunch',
      date: DateTime.now(),
    );

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountsStreamProvider.overrideWith((ref) => Stream.value([account])),
          settingsProvider.overrideWith((ref) => Stream.value(SettingsEntity())),
          transactionRepositoryProvider.overrideWithValue(fakeRepo),
          transactionControllerProvider.overrideWith((ref) => TestTransactionController(ref, fakeRepo)),
        ],
        child: MaterialApp(
          home: AddEditTransactionScreen(transaction: initialTx),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial edit state
    expect(find.text('Edit Transaction'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('45.0'), findsOneWidget);

    // Tap Update Transaction
    await tester.ensureVisible(find.text('Update Transaction'));
    await tester.tap(find.text('Update Transaction'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Success bottom sheet appears with 'Add Another'
    expect(find.text('Add Another'), findsOneWidget);

    // Tap Add Another
    await tester.tap(find.text('Add Another'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify form is now blank and title changed to 'Add Transaction'
    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Lunch'), findsNothing);
    expect(find.text('45.0'), findsNothing);
  });
}
