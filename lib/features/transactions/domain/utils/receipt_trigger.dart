import '../entities/transaction_event_bus.dart';

class ReceiptTrigger {
  final TransactionEventBus _eventBus;

  ReceiptTrigger(this._eventBus) {
    _eventBus.stream.listen(_onTransactionEvent);
  }

  void _onTransactionEvent(TransactionEvent event) {
    switch (event.type) {
      case TransactionEventType.transactionDeleted:
        _handleTransactionDeletion(event.transactionUuid);
        break;
      default:
        break;
    }
  }

  void _handleTransactionDeletion(String transactionUuid) {
    // Cascade delete/unlink associated local and cloud receipt files
  }
}
