import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/category_data.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/utils/category_aggregator.dart';

/// Implementation of category repository
class CategoryRepositoryImpl implements CategoryRepository {
  final TransactionRepository _transactionRepository;

  CategoryRepositoryImpl(this._transactionRepository);

  @override
  Future<CategoryAnalyticsReport> getCategoryAnalytics(String timeFilter) async {
    final transactions = await _transactionRepository.getTransactions();
    return CategoryAggregator.aggregate(
      transactions: transactions,
      timeFilter: timeFilter,
    );
  }

  @override
  Stream<CategoryAnalyticsReport> watchCategoryAnalytics(String timeFilter) {
    return _transactionRepository.watchTransactions().map(
      (transactions) => CategoryAggregator.aggregate(
        transactions: transactions,
        timeFilter: timeFilter,
      ),
    );
  }

  @override
  Future<CategoryDetails> getCategoryDetails(
    String categoryName,
    String timeFilter,
  ) async {
    final transactions = await _transactionRepository.getTransactions();
    return CategoryAggregator.getCategoryDetails(
      transactions: transactions,
      categoryName: categoryName,
      timeFilter: timeFilter,
    );
  }

  @override
  Future<List<CategoryRanking>> getCategoryRankings(String timeFilter) async {
    final report = await getCategoryAnalytics(timeFilter);
    return report.rankings;
  }

  @override
  Future<List<CategoryRanking>> getExpenseCategories(String timeFilter) async {
    final report = await getCategoryAnalytics(timeFilter);
    return report.expenseCategories;
  }

  @override
  Future<List<CategoryRanking>> getIncomeCategories(String timeFilter) async {
    final report = await getCategoryAnalytics(timeFilter);
    return report.incomeCategories;
  }

  @override
  Future<List<CategoryPeriodComparison>> getCategoryComparison(
    String timeFilter,
  ) async {
    final report = await getCategoryAnalytics(timeFilter);
    return report.comparisons;
  }
}
