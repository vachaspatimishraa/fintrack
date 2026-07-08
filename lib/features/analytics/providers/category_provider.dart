import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/repositories/category_repository_impl.dart';
import '../domain/entities/category_data.dart';
import '../domain/repositories/category_repository.dart';
import '../presentation/controllers/category_controller.dart';

final categoryTimeFilterProvider = StateProvider<String>((ref) => 'month');

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return CategoryRepositoryImpl(transactionRepo);
});

final categoryControllerProvider = Provider<CategoryController>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryController(repository, ref);
});

final categoryAnalyticsReportProvider = StreamProvider<CategoryAnalyticsReport>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  final filter = ref.watch(categoryTimeFilterProvider);
  return repo.watchCategoryAnalytics(filter);
});

/// Provider for category insights
final categoryInsightsProvider = Provider<List<String>>((ref) {
  final reportAsync = ref.watch(categoryAnalyticsReportProvider);
  final controller = ref.watch(categoryControllerProvider);

  return reportAsync.when(
    data: (report) => controller.generateInsights(report),
    loading: () => [],
    error: (err, stack) => [],
  );
});

/// Provider for period label
final categoryPeriodLabelProvider = Provider<String>((ref) {
  final filter = ref.watch(categoryTimeFilterProvider);
  final controller = ref.watch(categoryControllerProvider);
  return controller.getPeriodLabel(filter);
});

/// Provider for category details
final categoryDetailsProvider =
    FutureProvider.family<CategoryDetails, String>((ref, categoryName) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final filter = ref.watch(categoryTimeFilterProvider);
  return repo.getCategoryDetails(categoryName, filter);
});

/// Provider for expense categories
final expenseCategoriesProvider = FutureProvider<List<CategoryRanking>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final filter = ref.watch(categoryTimeFilterProvider);
  return repo.getExpenseCategories(filter);
});

/// Provider for income categories
final incomeCategoriesProvider = FutureProvider<List<CategoryRanking>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final filter = ref.watch(categoryTimeFilterProvider);
  return repo.getIncomeCategories(filter);
});

/// Provider for category comparisons
final categoryComparisonsProvider = FutureProvider<List<CategoryPeriodComparison>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final filter = ref.watch(categoryTimeFilterProvider);
  return repo.getCategoryComparison(filter);
});
