import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/cash_flow_data.dart';
import '../../domain/repositories/cash_flow_repository.dart';
import '../../domain/utils/cash_flow_aggregators.dart';

class CashFlowRepositoryImpl implements CashFlowRepository {
  final TransactionRepository _transactionRepository;

  CashFlowRepositoryImpl(this._transactionRepository);

  @override
  Future<CashFlowReport> getCashFlowReport(String filter) async {
    final list = await _transactionRepository.getTransactions();
    return CashFlowAggregators.aggregate(transactions: list, timeFilter: filter);
  }

  @override
  Stream<CashFlowReport> watchCashFlowReport(String filter) {
    return _transactionRepository.watchTransactions().map((list) {
      return CashFlowAggregators.aggregate(transactions: list, timeFilter: filter);
    });
  }
}
