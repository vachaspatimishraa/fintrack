import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/yearly_report_data.dart';
import '../presentation/controllers/yearly_report_controller.dart';
import 'analytics_provider.dart';

final selectedYearProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final yearlyReportProvider = StreamProvider<YearlyReport>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  final anchor = ref.watch(selectedYearProvider);
  return repository.watchYearlyReports(anchor);
});

final yearlyReportControllerProvider = Provider<YearlyReportController>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return YearlyReportController(repository, ref);
});
