import '../../domain/entities/transaction_entity.dart';

class TransferService {
  static List<TransactionEntity> createTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime date,
    required String currency,
    String? category,
  }) {
    // Expense
    final expense = TransactionEntity(
      uuid: '',
      accountId: fromAccountId,
      type: 'expense',
      categoryId: category ?? 'Transfer',
      category: category ?? 'Transfer',
      amount: amount,
      title: 'Transfer to wallet',
      description: 'Transfer of funds',
      currency: currency,
      paymentMethod: 'Bank Transfer',
      isDeleted: false,
      isSynced: false,
      isRecurring: false,
      date: date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncVersion: 1,
    );

    // Income
    final income = TransactionEntity(
      uuid: '',
      accountId: toAccountId,
      type: 'income',
      categoryId: category ?? 'Transfer',
      category: category ?? 'Transfer',
      amount: amount,
      title: 'Transfer from wallet',
      description: 'Transfer of funds',
      currency: currency,
      paymentMethod: 'Bank Transfer',
      isDeleted: false,
      isSynced: false,
      isRecurring: false,
      date: date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncVersion: 1,
    );

    return [expense, income];
  }
}
