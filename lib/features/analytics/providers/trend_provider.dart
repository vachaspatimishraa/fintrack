import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../data/repositories/spending_trend_repository_impl.dart';
import '../domain/entities/spending_trend_data.dart';
import '../domain/repositories/spending_trend_repository.dart';
import '../presentation/controllers/trend_controller.dart';

final trendTimeFilterProvider = StateProvider<String>((ref) => 'month');

final spendingTrendRepositoryProvider = Provider<SpendingTrendRepository>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return SpendingTrendRepositoryImpl(transactionRepo);
});

final trendControllerProvider = Provider<TrendController>((ref) {
  final repository = ref.watch(spendingTrendRepositoryProvider);
  return TrendController(repository, ref);
});

final spendingTrendReportProvider = StreamProvider<SpendingTrendReport>((ref) {
  final repository = ref.watch(spendingTrendRepositoryProvider);
  final filter = ref.watch(trendTimeFilterProvider);
  return repository.watchTrendAnalytics(filter);
});

final trendRecommendationsProvider = Provider<List<String>>((ref) {
  final reportAsync = ref.watch(spendingTrendReportProvider);
  final controller = ref.watch(trendControllerProvider);
  return reportAsync.when(
    data: controller.generateRecommendations,
    loading: () => [],
    error: (error, stack) => [],
  );
});

final trendPeriodLabelProvider = Provider<String>((ref) {
  final filter = ref.watch(trendTimeFilterProvider);
  final controller = ref.watch(trendControllerProvider);
  return controller.getPeriodLabel(filter);
});
