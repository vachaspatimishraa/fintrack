import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/calendar_analytics_data.dart';
import '../../domain/repositories/calendar_analytics_repository.dart';
import '../../domain/utils/activity_streak_service.dart';
import '../../domain/utils/calendar_analytics_engine.dart';

class CalendarAnalyticsRepositoryImpl implements CalendarAnalyticsRepository {
  final TransactionRepository _transactionRepository;

  CalendarAnalyticsRepositoryImpl(this._transactionRepository);

  @override
  Future<CalendarAnalyticsReport> getCalendarData(
    DateTime visibleMonth, {
    bool includeIncome = true,
    bool includeExpense = true,
  }) async {
    final transactions = await _transactionRepository.getTransactions();
    return CalendarAnalyticsEngine.aggregate(
      transactions: transactions,
      visibleMonth: visibleMonth,
      includeIncome: includeIncome,
      includeExpense: includeExpense,
    );
  }

  @override
  Future<CalendarDayData> getDaySummary(DateTime date) async {
    final transactions = await _transactionRepository.getTransactions();
    return CalendarAnalyticsEngine.getDaySummary(
      transactions: transactions,
      date: date,
    );
  }

  @override
  Future<CalendarPeriodSummary> getWeekSummary(DateTime date) async {
    final transactions = await _transactionRepository.getTransactions();
    return CalendarAnalyticsEngine.getWeekSummary(
      transactions: transactions,
      date: date,
    );
  }

  @override
  Future<CalendarPeriodSummary> getMonthSummary(DateTime month) async {
    final transactions = await _transactionRepository.getTransactions();
    return CalendarAnalyticsEngine.getMonthSummary(
      transactions: transactions,
      month: month,
    );
  }

  @override
  Future<CalendarPeriodSummary> getYearSummary(int year) async {
    final transactions = await _transactionRepository.getTransactions();
    return CalendarAnalyticsEngine.getYearSummary(
      transactions: transactions,
      year: year,
    );
  }

  @override
  Future<List<CalendarDayData>> getHeatmap(DateTime visibleMonth) async {
    final report = await getCalendarData(visibleMonth);
    return report.days;
  }

  @override
  Future<List<CalendarTransactionItem>> getDailyTransactions(DateTime date) async {
    final transactions = await _transactionRepository.getTransactions();
    return CalendarAnalyticsEngine.getDailyTransactions(
      transactions: transactions,
      date: date,
    );
  }

  @override
  Future<ActivityStreak> getActivityStreak(DateTime visibleMonth) async {
    final report = await getCalendarData(visibleMonth);
    return ActivityStreakService.calculate(report.days);
  }

  @override
  Stream<CalendarAnalyticsReport> watchCalendarAnalytics(
    DateTime visibleMonth, {
    bool includeIncome = true,
    bool includeExpense = true,
  }) {
    return _transactionRepository.watchTransactions().map((transactions) {
      return CalendarAnalyticsEngine.aggregate(
        transactions: transactions,
        visibleMonth: visibleMonth,
        includeIncome: includeIncome,
        includeExpense: includeExpense,
      );
    });
  }
}
