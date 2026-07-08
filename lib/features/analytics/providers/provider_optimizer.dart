import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'monthly_report_provider.dart';

final monthlySavingsOnlyProvider = Provider<double>((ref) {
  final reportAsync = ref.watch(monthlyReportProvider);
  return reportAsync.maybeWhen(
    data: (report) => report.summary.savings,
    orElse: () => 0.0,
  );
});

final monthlyIncomeOnlyProvider = Provider<double>((ref) {
  final reportAsync = ref.watch(monthlyReportProvider);
  return reportAsync.maybeWhen(
    data: (report) => report.summary.income,
    orElse: () => 0.0,
  );
});

final monthlyExpenseOnlyProvider = Provider<double>((ref) {
  final reportAsync = ref.watch(monthlyReportProvider);
  return reportAsync.maybeWhen(
    data: (report) => report.summary.expense,
    orElse: () => 0.0,
  );
});
