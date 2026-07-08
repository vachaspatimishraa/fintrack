import '../../domain/entities/transaction_entity.dart';

class TransactionTemplateService {
  static TransactionEntity applyTemplate(TransactionEntity template, {double? newAmount}) {
    return template.copyWith(
      uuid: '',
      amount: newAmount ?? template.amount,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );
  }
}
