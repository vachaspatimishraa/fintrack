import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/expense_data.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/utils/expense_aggregator.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final TransactionRepository _transactionRepository;

  ExpenseRepositoryImpl(this._transactionRepository);

  @override
  Future<ExpenseReport> getExpenseReport(String filter) async {
    final list = await _transactionRepository.getTransactions();
    return ExpenseAggregator.aggregate(transactions: list, timeFilter: filter);
  }

  @override
  Stream<ExpenseReport> watchExpenseReport(String filter) {
    return _transactionRepository.watchTransactions().map((list) {
      return ExpenseAggregator.aggregate(transactions: list, timeFilter: filter);
    });
  }
}
