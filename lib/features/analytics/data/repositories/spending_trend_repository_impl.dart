import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/spending_trend_data.dart';
import '../../domain/repositories/spending_trend_repository.dart';
import '../../domain/utils/trend_engine.dart';

class SpendingTrendRepositoryImpl implements SpendingTrendRepository {
  final TransactionRepository _transactionRepository;

  SpendingTrendRepositoryImpl(this._transactionRepository);

  @override
  Future<SpendingTrendReport> getSpendingTrend(String timeFilter) async {
    final transactions = await _transactionRepository.getTransactions();
    return TrendEngine.aggregate(
      transactions: transactions,
      timeFilter: timeFilter,
    );
  }

  @override
  Future<SpendingTrendReport> getDailyTrend() async {
    final transactions = await _transactionRepository.getTransactions();
    return TrendEngine.getDailyTrend(transactions);
  }

  @override
  Future<SpendingTrendReport> getWeeklyTrend() async {
    final transactions = await _transactionRepository.getTransactions();
    return TrendEngine.getWeeklyTrend(transactions);
  }

  @override
  Future<SpendingTrendReport> getMonthlyTrend() async {
    final transactions = await _transactionRepository.getTransactions();
    return TrendEngine.getMonthlyTrend(transactions);
  }

  @override
  Future<SpendingTrendReport> getYearlyTrend() async {
    final transactions = await _transactionRepository.getTransactions();
    return TrendEngine.getYearlyTrend(transactions);
  }

  @override
  Future<List<SpendingTrendPoint>> getMovingAverage(String timeFilter) async {
    final report = await getSpendingTrend(timeFilter);
    return report.points;
  }

  @override
  Future<SpendingForecast> getTrendForecast(String timeFilter) async {
    final report = await getSpendingTrend(timeFilter);
    return report.forecast;
  }

  @override
  Future<List<TrendComparison>> getTrendComparison(String timeFilter) async {
    final report = await getSpendingTrend(timeFilter);
    return report.comparisons;
  }

  @override
  Stream<SpendingTrendReport> watchTrendAnalytics(String timeFilter) {
    return _transactionRepository.watchTransactions().map((transactions) {
      return TrendEngine.aggregate(
        transactions: transactions,
        timeFilter: timeFilter,
      );
    });
  }
}
