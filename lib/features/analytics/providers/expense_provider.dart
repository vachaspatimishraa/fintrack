import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/repositories/expense_repository_impl.dart';
import '../domain/entities/expense_data.dart';
import '../domain/repositories/expense_repository.dart';
import '../presentation/controllers/expense_controller.dart';

final expenseTimeFilterProvider = StateProvider<String>((ref) => '30days');

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return ExpenseRepositoryImpl(transactionRepo);
});

final expenseControllerProvider = Provider<ExpenseController>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return ExpenseController(repository, ref);
});

final expenseReportProvider = StreamProvider<ExpenseReport>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  final filter = ref.watch(expenseTimeFilterProvider);
  return repo.watchExpenseReport(filter);
});

/// Provider for expense insights based on current report
final expenseInsightsProvider = Provider<List<String>>((ref) {
  final reportAsync = ref.watch(expenseReportProvider);
  final controller = ref.watch(expenseControllerProvider);

  return reportAsync.when(
    data: (report) => controller.generateInsights(report),
    loading: () => [],
    error: (err, stack) => [],
  );
});

/// Provider for period comparison label
final expensePeriodLabelProvider = Provider<String>((ref) {
  final filter = ref.watch(expenseTimeFilterProvider);
  final controller = ref.watch(expenseControllerProvider);
  return controller.getPeriodLabel(filter);
});

/// Provider for expense health status
final expenseHealthStatusProvider = Provider<(String, String)>((ref) {
  final reportAsync = ref.watch(expenseReportProvider);

  return reportAsync.when(
    data: (report) => (report.healthScore.grade, report.healthScore.status),
    loading: () => ('—', 'Loading'),
    error: (err, stack) => ('F', 'Error'),
  );
});
