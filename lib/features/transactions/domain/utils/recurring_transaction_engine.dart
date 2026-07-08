import '../../domain/entities/transaction_entity.dart';

class RecurringTransactionEngine {
  static DateTime calculateNextExecution(DateTime lastExecution, String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return lastExecution.add(const Duration(days: 1));
      case 'weekly':
        return lastExecution.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(lastExecution.year, lastExecution.month + 1, lastExecution.day);
      case 'quarterly':
        return DateTime(lastExecution.year, lastExecution.month + 3, lastExecution.day);
      case 'yearly':
        return DateTime(lastExecution.year + 1, lastExecution.month, lastExecution.day);
      default:
        return lastExecution.add(const Duration(days: 30));
    }
  }

  static TransactionEntity generateNextInstance(TransactionEntity template, DateTime nextDate) {
    return template.copyWith(
      uuid: '',
      date: nextDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );
  }
}
