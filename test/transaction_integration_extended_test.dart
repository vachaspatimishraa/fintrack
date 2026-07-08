import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_event_bus.dart';
import 'package:fintrack/features/transactions/domain/utils/conflict_resolver.dart';

void main() {
  group('Transaction Integration & Sync Coordination Tests', () {
    late TransactionEntity localTx;
    late TransactionEntity remoteTx;

    setUp(() {
      localTx = TransactionEntity(
        uuid: 'tx-123',
        accountId: 'acc-1',
        type: 'expense',
        categoryId: 'Food',
        category: 'Food',
        amount: 25.0,
        title: 'Lunch',
        description: 'Tacos',
        currency: 'USD',
        paymentMethod: 'Cash',
        tags: const [],
        isDeleted: false,
        isSynced: false,
        isRecurring: false,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        syncVersion: 1,
      );

      remoteTx = TransactionEntity(
        uuid: 'tx-123',
        accountId: 'acc-1',
        type: 'expense',
        categoryId: 'Food',
        category: 'Food',
        amount: 25.0,
        title: 'Lunch',
        description: 'Tacos',
        currency: 'USD',
        paymentMethod: 'Cash',
        tags: const [],
        isDeleted: false,
        isSynced: true,
        isRecurring: false,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), // Remote is newer
        syncVersion: 2,
      );
    });

    test('ConflictResolver selects downloadCloud when Remote is newer', () {
      final resolution = ConflictResolver.resolve(local: localTx, remote: remoteTx);
      expect(resolution, equals(ConflictResolutionAction.downloadCloud));
    });

    test('ConflictResolver selects uploadLocal when Local is newer', () {
      final updatedLocal = localTx.copyWith(updatedAt: DateTime.now().add(const Duration(minutes: 10)));
      final resolution = ConflictResolver.resolve(local: updatedLocal, remote: remoteTx);
      expect(resolution, equals(ConflictResolutionAction.uploadLocal));
    });

    test('TransactionEventBus publishes and receives events', () async {
      final bus = TransactionEventBus();
      final futureEvent = bus.stream.first;

      bus.publish(const TransactionEvent(
        type: TransactionEventType.transactionCreated,
        transactionUuid: 'tx-123',
      ));

      final event = await futureEvent;
      expect(event.type, equals(TransactionEventType.transactionCreated));
      expect(event.transactionUuid, equals('tx-123'));
    });
  });
}
