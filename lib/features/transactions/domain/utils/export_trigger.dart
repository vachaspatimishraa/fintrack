import '../entities/transaction_event_bus.dart';

class ExportTrigger {
  final TransactionEventBus _eventBus;

  ExportTrigger(this._eventBus) {
    _eventBus.stream.listen(_onTransactionEvent);
  }

  void _onTransactionEvent(TransactionEvent event) {
    // Invalidate cached export formats (PDF, Excel, CSV) when transactions change
    switch (event.type) {
      case TransactionEventType.transactionCreated:
      case TransactionEventType.transactionUpdated:
      case TransactionEventType.transactionDeleted:
      case TransactionEventType.transactionRestored:
        _invalidateCache();
        break;
      default:
        break;
    }
  }

  void _invalidateCache() {
    // Invalidate exported document caches
  }
}
