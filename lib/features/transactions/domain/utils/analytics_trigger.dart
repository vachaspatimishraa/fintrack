import '../entities/transaction_event_bus.dart';

class AnalyticsTrigger {
  final TransactionEventBus _eventBus;

  AnalyticsTrigger(this._eventBus) {
    _eventBus.stream.listen(_onTransactionEvent);
  }

  void _onTransactionEvent(TransactionEvent event) {
    // When transactions mutate, analytics triggers recalculation of balances & distributions
    switch (event.type) {
      case TransactionEventType.transactionCreated:
      case TransactionEventType.transactionUpdated:
      case TransactionEventType.transactionDeleted:
      case TransactionEventType.transactionRestored:
        _recalculate();
        break;
      default:
        break;
    }
  }

  void _recalculate() {
    // Trigger calculation of Daily, Weekly, Monthly, Yearly cash flow aggregates
  }
}
