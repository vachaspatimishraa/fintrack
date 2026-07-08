import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/monthly_report_data.dart';
import '../presentation/controllers/monthly_report_controller.dart';
import 'analytics_provider.dart';

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final monthlyReportProvider = StreamProvider<MonthlyReport>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  final anchor = ref.watch(selectedMonthProvider);
  return repository.watchMonthlyReports(anchor);
});

final monthlyReportControllerProvider = Provider<MonthlyReportController>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return MonthlyReportController(repository, ref);
});
