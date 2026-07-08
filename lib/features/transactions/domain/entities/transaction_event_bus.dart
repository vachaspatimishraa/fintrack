import 'dart:async';

enum TransactionEventType {
  transactionCreated,
  transactionUpdated,
  transactionDeleted,
  transactionRestored,
  transactionDuplicated,
  receiptAttached,
  receiptRemoved,
  syncCompleted,
  conflictResolved
}

class TransactionEvent {
  final TransactionEventType type;
  final String transactionUuid;
  final Map<String, dynamic> payload;

  const TransactionEvent({
    required this.type,
    required this.transactionUuid,
    this.payload = const {},
  });
}

class TransactionEventBus {
  static final TransactionEventBus _instance = TransactionEventBus._internal();
  factory TransactionEventBus() => _instance;
  TransactionEventBus._internal();

  final StreamController<TransactionEvent> _controller = StreamController<TransactionEvent>.broadcast();

  Stream<TransactionEvent> get stream => _controller.stream;

  void publish(TransactionEvent event) {
    _controller.add(event);
  }
}
