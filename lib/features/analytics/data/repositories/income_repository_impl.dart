import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/income_data.dart';
import '../../domain/repositories/income_repository.dart';
import '../../domain/utils/income_aggregator.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final TransactionRepository _transactionRepository;

  IncomeRepositoryImpl(this._transactionRepository);

  @override
  Future<IncomeReport> getIncomeReport(String filter) async {
    final list = await _transactionRepository.getTransactions();
    return IncomeAggregator.aggregate(transactions: list, timeFilter: filter);
  }

  @override
  Stream<IncomeReport> watchIncomeReport(String filter) {
    return _transactionRepository.watchTransactions().map((list) {
      return IncomeAggregator.aggregate(transactions: list, timeFilter: filter);
    });
  }
}
