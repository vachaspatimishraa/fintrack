import 'dart:async';
import 'package:fintrack/features/transactions/domain/entities/transaction_event_bus.dart';

class TransactionObserver {
  final TransactionEventBus _eventBus;
  StreamSubscription? _subscription;

  TransactionObserver(this._eventBus);

  void startObserving(void Function(TransactionEvent event) onEventDispatched) {
    _subscription = _eventBus.stream.listen(onEventDispatched);
  }

  void stopObserving() {
    _subscription?.cancel();
  }
}
