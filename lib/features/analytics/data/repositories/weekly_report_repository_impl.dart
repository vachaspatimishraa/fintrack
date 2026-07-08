import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/weekly_report_data.dart';
import '../../domain/repositories/weekly_report_repository.dart';
import '../../domain/utils/weekly_aggregator.dart';

class WeeklyReportRepositoryImpl implements WeeklyReportRepository {
  final TransactionRepository _transactionRepository;

  WeeklyReportRepositoryImpl(this._transactionRepository);

  @override
  Future<WeeklyReport> getWeeklyReport(DateTime weekAnchor) async {
    final transactions = await _transactionRepository.getTransactions();
    return WeeklyAggregator.aggregate(
      transactions: transactions,
      weekAnchor: weekAnchor,
    );
  }

  @override
  Future<WeeklySummary> getWeeklySummary(DateTime weekAnchor) async {
    return (await getWeeklyReport(weekAnchor)).summary;
  }

  @override
  Future<WeeklyStatistics> getWeeklyStatistics(DateTime weekAnchor) async {
    return (await getWeeklyReport(weekAnchor)).statistics;
  }

  @override
  Future<List<WeeklyCategoryBreakdown>> getWeeklyCategories(
    DateTime weekAnchor,
  ) async {
    return (await getWeeklyReport(weekAnchor)).categories;
  }

  @override
  Future<List<WeeklyTransactionItem>> getWeeklyTimeline(
    DateTime weekAnchor,
  ) async {
    return (await getWeeklyReport(weekAnchor)).timeline;
  }

  @override
  Future<WeeklyComparison> getWeeklyComparison(DateTime weekAnchor) async {
    return (await getWeeklyReport(weekAnchor)).comparison;
  }

  @override
  Future<WeeklyScore> getWeeklyScore(DateTime weekAnchor) async {
    return (await getWeeklyReport(weekAnchor)).score;
  }

  @override
  Stream<WeeklyReport> watchWeeklyReports(DateTime weekAnchor) {
    return _transactionRepository.watchTransactions().map((transactions) {
      return WeeklyAggregator.aggregate(
        transactions: transactions,
        weekAnchor: weekAnchor,
      );
    });
  }
}
