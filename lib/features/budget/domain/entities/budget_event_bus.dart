import 'dart:async';

enum BudgetEventType {
  budgetCreated,
  budgetUpdated,
  budgetDeleted,
  budgetRestored,
  syncCompleted
}

class BudgetEvent {
  final BudgetEventType type;
  final String budgetUuid;
  final Map<String, dynamic> payload;

  const BudgetEvent({
    required this.type,
    required this.budgetUuid,
    this.payload = const {},
  });
}

class BudgetEventBus {
  static final BudgetEventBus _instance = BudgetEventBus._internal();
  factory BudgetEventBus() => _instance;
  BudgetEventBus._internal();

  final StreamController<BudgetEvent> _controller = StreamController<BudgetEvent>.broadcast();

  Stream<BudgetEvent> get stream => _controller.stream;

  void publish(BudgetEvent event) {
    _controller.add(event);
  }
}
