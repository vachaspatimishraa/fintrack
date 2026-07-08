import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../data/repositories/calendar_analytics_repository_impl.dart';
import '../domain/entities/calendar_analytics_data.dart';
import '../domain/repositories/calendar_analytics_repository.dart';
import '../presentation/controllers/calendar_controller.dart';

final calendarVisibleMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final calendarSelectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final calendarIncludeIncomeProvider = StateProvider<bool>((ref) => true);

final calendarIncludeExpenseProvider = StateProvider<bool>((ref) => true);

final calendarAnalyticsRepositoryProvider =
    Provider<CalendarAnalyticsRepository>((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  return CalendarAnalyticsRepositoryImpl(transactionRepository);
});

final calendarControllerProvider = Provider<CalendarController>((ref) {
  final repository = ref.watch(calendarAnalyticsRepositoryProvider);
  return CalendarController(repository, ref);
});

final calendarAnalyticsReportProvider =
    StreamProvider<CalendarAnalyticsReport>((ref) {
  final repository = ref.watch(calendarAnalyticsRepositoryProvider);
  final visibleMonth = ref.watch(calendarVisibleMonthProvider);
  final includeIncome = ref.watch(calendarIncludeIncomeProvider);
  final includeExpense = ref.watch(calendarIncludeExpenseProvider);
  return repository.watchCalendarAnalytics(
    visibleMonth,
    includeIncome: includeIncome,
    includeExpense: includeExpense,
  );
});

final selectedCalendarDayProvider = Provider<CalendarDayData?>((ref) {
  final report = ref.watch(calendarAnalyticsReportProvider);
  final selectedDate = ref.watch(calendarSelectedDateProvider);
  final controller = ref.watch(calendarControllerProvider);
  return report.when(
    data: (data) => controller.selectedDay(data, selectedDate),
    loading: () => null,
    error: (error, stack) => null,
  );
});

final selectedDayTransactionsProvider =
    FutureProvider<List<CalendarTransactionItem>>((ref) async {
  final repository = ref.watch(calendarAnalyticsRepositoryProvider);
  final selectedDate = ref.watch(calendarSelectedDateProvider);
  return repository.getDailyTransactions(selectedDate);
});
