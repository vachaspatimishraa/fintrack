import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/budget_query_filter.dart';
import '../../domain/utils/budget_pagination_service.dart';
import '../../providers/budget_provider.dart';

class BudgetListState {
  final List<BudgetEntity> budgets;
  final BudgetQueryFilter filter;
  final bool isLoading;
  final bool isLoadMore;
  final bool hasMore;
  final int offset;
  final String? error;

  const BudgetListState({
    this.budgets = const [],
    this.filter = const BudgetQueryFilter(),
    this.isLoading = false,
    this.isLoadMore = false,
    this.hasMore = true,
    this.offset = 0,
    this.error,
  });

  BudgetListState copyWith({
    List<BudgetEntity>? budgets,
    BudgetQueryFilter? filter,
    bool? isLoading,
    bool? isLoadMore,
    bool? hasMore,
    int? offset,
    String? error,
  }) {
    return BudgetListState(
      budgets: budgets ?? this.budgets,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      error: error ?? this.error,
    );
  }
}

class BudgetListNotifier extends StateNotifier<BudgetListState> {
  final Ref _ref;
  static const int _pageSize = 20;

  BudgetListNotifier(this._ref) : super(const BudgetListState()) {
    loadInitial();
  }

  String get _currentUserId => _ref.read(authProvider).user?.id ?? '';

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null, offset: 0, hasMore: true);
    try {
      final paginationService = BudgetPaginationService(_ref.read(budgetLocalDatasourceProvider));
      final results = await paginationService.fetchPage(
        ownerId: _currentUserId,
        limit: _pageSize,
        offset: 0,
        status: state.filter.status,
        budgetType: state.filter.budgetType,
      );

      state = state.copyWith(
        budgets: results,
        isLoading: false,
        hasMore: results.length >= _pageSize,
        offset: results.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadMore || !state.hasMore) return;

    state = state.copyWith(isLoadMore: true, error: null);
    try {
      final paginationService = BudgetPaginationService(_ref.read(budgetLocalDatasourceProvider));
      final results = await paginationService.fetchPage(
        ownerId: _currentUserId,
        limit: _pageSize,
        offset: state.offset,
        status: state.filter.status,
        budgetType: state.filter.budgetType,
      );

      state = state.copyWith(
        budgets: [...state.budgets, ...results],
        isLoadMore: false,
        hasMore: results.length >= _pageSize,
        offset: state.offset + results.length,
      );
    } catch (e) {
      state = state.copyWith(isLoadMore: false, error: e.toString());
    }
  }

  void updateFilter(BudgetQueryFilter newFilter) {
    state = state.copyWith(filter: newFilter);
    loadInitial();
  }

  void setQuery(String query) {
    state = state.copyWith(filter: state.filter.copyWith(query: query));
  }

  void setStatus(String? status) {
    updateFilter(state.filter.copyWith(
      status: status,
      clearStatus: status == null,
    ));
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(filter: state.filter.copyWith(sortBy: sortBy));
  }

  List<BudgetEntity> get filteredBudgets {
    var list = List<BudgetEntity>.from(state.budgets);

    // Apply query filter locally for responsiveness on already loaded data
    if (state.filter.query.isNotEmpty) {
      final q = state.filter.query.toLowerCase();
      list = list.where((b) => 
        b.title.toLowerCase().contains(q) || 
        (b.description?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    // Sort
    switch (state.filter.sortBy) {
      case 'name':
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'oldest':
        list.sort((a, b) => a.startDate.compareTo(b.startDate));
        break;
      case 'amount_high':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_low':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'progress_high':
        list.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'progress_low':
        list.sort((a, b) => a.progress.compareTo(b.progress));
        break;
      case 'newest':
      default:
        list.sort((a, b) => b.startDate.compareTo(a.startDate));
        break;
    }

    return list;
  }
}

final budgetListProvider = StateNotifierProvider<BudgetListNotifier, BudgetListState>((ref) {
  return BudgetListNotifier(ref);
});

final filteredBudgetsProvider = Provider<List<BudgetEntity>>((ref) {
  return ref.watch(budgetListProvider.notifier).filteredBudgets;
});
