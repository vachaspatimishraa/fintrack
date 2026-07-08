import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../data/repositories/weekly_report_repository_impl.dart';
import '../domain/entities/weekly_report_data.dart';
import '../domain/repositories/weekly_report_repository.dart';
import '../presentation/controllers/weekly_report_controller.dart';

final weeklyReportAnchorProvider = StateProvider<DateTime>((ref) => DateTime.now());

final weeklyReportRepositoryProvider = Provider<WeeklyReportRepository>((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  return WeeklyReportRepositoryImpl(transactionRepository);
});

final weeklyReportControllerProvider = Provider<WeeklyReportController>((ref) {
  final repository = ref.watch(weeklyReportRepositoryProvider);
  return WeeklyReportController(repository, ref);
});

final weeklyReportProvider = StreamProvider<WeeklyReport>((ref) {
  final repository = ref.watch(weeklyReportRepositoryProvider);
  final anchor = ref.watch(weeklyReportAnchorProvider);
  return repository.watchWeeklyReports(anchor);
});

final weeklyRecommendationsProvider = Provider<List<String>>((ref) {
  final report = ref.watch(weeklyReportProvider);
  final controller = ref.watch(weeklyReportControllerProvider);
  return report.when(
    data: controller.recommendations,
    loading: () => [],
    error: (error, stack) => [],
  );
});
