import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/budget_analytics_repository_impl.dart';
import '../domain/entities/budget_analytics.dart';
import '../domain/entities/budget_history_record.dart';
import '../domain/entities/budget_insight.dart';
import '../domain/repositories/budget_analytics_repository.dart';
import 'budget_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

final budgetAnalyticsRepositoryProvider = Provider<BudgetAnalyticsRepository>((ref) {
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return BudgetAnalyticsRepositoryImpl(
    budgetRepository: budgetRepo,
    transactionRepository: transactionRepo,
  );
});

final budgetAnalyticsProvider = FutureProvider<BudgetAnalytics>((ref) {
  final repository = ref.watch(budgetAnalyticsRepositoryProvider);
  return repository.getBudgetAnalytics();
});

final budgetHistoryProvider = FutureProvider<List<BudgetHistoryRecord>>((ref) {
  final repository = ref.watch(budgetAnalyticsRepositoryProvider);
  return repository.getBudgetHistory();
});

final budgetInsightsProvider = FutureProvider<List<BudgetInsight>>((ref) {
  final repository = ref.watch(budgetAnalyticsRepositoryProvider);
  return repository.getBudgetInsights();
});

final categorySpendingProvider = FutureProvider<Map<String, double>>((ref) {
  final repository = ref.watch(budgetAnalyticsRepositoryProvider);
  return repository.getCategorySpending();
});

final monthlyTrendsProvider = FutureProvider<Map<String, double>>((ref) {
  final repository = ref.watch(budgetAnalyticsRepositoryProvider);
  return repository.getMonthlyTrends();
});
