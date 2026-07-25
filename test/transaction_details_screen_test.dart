import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fintrack/features/transactions/presentation/screens/transaction_details_screen.dart';
import 'package:fintrack/features/transactions/providers/transaction_provider.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_query_filter.dart';
import 'package:fintrack/features/accounts/providers/account_provider.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';

class FakeTransactionRepository implements TransactionRepository {
  final StreamController<List<TransactionEntity>> _controller = StreamController<List<TransactionEntity>>.broadcast();
  List<TransactionEntity> currentList = [];

  FakeTransactionRepository(TransactionEntity initialTx) {
    currentList = [initialTx];
  }

  void emit(List<TransactionEntity> list) {
    currentList = list;
    _controller.add(list);
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() async* {
    yield currentList;
    yield* _controller.stream;
  }

  @override
  Stream<TransactionEntity?> watchTransaction(String uuid) async* {
    yield currentList.isEmpty ? null : currentList.firstWhere((t) => t.uuid == uuid);
    yield* _controller.stream.map((list) => list.isEmpty ? null : list.firstWhere((t) => t.uuid == uuid));
  }

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions(int limit) async* {
    yield currentList;
    yield* _controller.stream;
  }

  @override
  Stream<List<TransactionEntity>> watchTransactionsByCategory(String category) => const Stream.empty();

  @override
  Stream<List<TransactionEntity>> watchTransactionsByDate(DateTime date) => const Stream.empty();

  @override
  Stream<List<TransactionEntity>> watchDeletedTransactions() => const Stream.empty();

  @override
  Stream<List<TransactionEntity>> watchPendingSyncTransactions() => const Stream.empty();

  @override
  Future<List<TransactionEntity>> getTransactions() async => currentList;

  @override
  Future<TransactionEntity?> getTransactionByUuid(String uuid) async =>
      currentList.isEmpty ? null : currentList.firstWhere((t) => t.uuid == uuid);

  @override
  Future<void> saveTransaction(TransactionEntity transaction) async {}

  @override
  Future<void> deleteTransaction(String uuid) async {
    currentList = [];
    _controller.add(currentList);
  }

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

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  testWidgets('TransactionDetailsScreen handles deletion and pops safely without black screen', (WidgetTester tester) async {
    final transaction = TransactionEntity(
      uuid: 'tx-123',
      title: 'Coffee',
      amount: 4.50,
      type: 'expense',
      category: 'Food',
      paymentMethod: 'Cash',
      date: DateTime.now(),
      accountId: 'acc-1',
    );

    final fakeRepo = FakeTransactionRepository(transaction);
    final account = AccountModel()
      ..uuid = 'acc-1'
      ..name = 'Cash Wallet'
      ..balance = 100.0;

    final homeKey = GlobalKey();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(fakeRepo),
          accountsStreamProvider.overrideWith((ref) => Stream.value([account])),
        ],
        child: MaterialApp(
          home: Scaffold(
            key: homeKey,
            body: const Text('Home Screen'),
          ),
          routes: {
            '/details': (context) => const TransactionDetailsScreen(transactionUuid: 'tx-123'),
          },
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Home Screen'), findsOneWidget);

    final context = tester.element(find.byKey(homeKey));
    Navigator.of(context).pushNamed('/details');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Coffee'), findsOneWidget);

    fakeRepo.emit([]);
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Home Screen'), findsOneWidget);
    expect(find.text('Coffee'), findsNothing);
  });
}
