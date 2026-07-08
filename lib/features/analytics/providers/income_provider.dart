import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/repositories/income_repository_impl.dart';
import '../domain/entities/income_data.dart';
import '../domain/repositories/income_repository.dart';
import '../presentation/controllers/income_controller.dart';

final incomeTimeFilterProvider = StateProvider<String>((ref) => '30days');

final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return IncomeRepositoryImpl(transactionRepo);
});

final incomeControllerProvider = Provider<IncomeController>((ref) {
  final repository = ref.watch(incomeRepositoryProvider);
  return IncomeController(repository, ref);
});

final incomeReportProvider = StreamProvider<IncomeReport>((ref) {
  final repo = ref.watch(incomeRepositoryProvider);
  final filter = ref.watch(incomeTimeFilterProvider);
  return repo.watchIncomeReport(filter);
});

/// Provider for income insights based on current report
final incomeInsightsProvider = Provider<List<String>>((ref) {
  final reportAsync = ref.watch(incomeReportProvider);
  final controller = ref.watch(incomeControllerProvider);

  return reportAsync.when(
    data: (report) => controller.generateInsights(report),
    loading: () => [],
    error: (err, stack) => [],
  );
});

/// Provider for period comparison label
final incomePeriodLabelProvider = Provider<String>((ref) {
  final filter = ref.watch(incomeTimeFilterProvider);
  final controller = ref.watch(incomeControllerProvider);
  return controller.getPeriodLabel(filter);
});
