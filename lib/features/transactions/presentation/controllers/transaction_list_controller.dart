import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_query_filter.dart';
import '../../providers/transaction_provider.dart';

class TransactionListState {
  final List<TransactionEntity> transactions;
  final TransactionQueryFilter filter;
  final bool isLoading;
  final bool isLoadMore;
  final bool hasMore;
  final int offset;
  final String? error;

  const TransactionListState({
    this.transactions = const [],
    this.filter = const TransactionQueryFilter(),
    this.isLoading = false,
    this.isLoadMore = false,
    this.hasMore = true,
    this.offset = 0,
    this.error,
  });

  TransactionListState copyWith({
    List<TransactionEntity>? transactions,
    TransactionQueryFilter? filter,
    bool? isLoading,
    bool? isLoadMore,
    bool? hasMore,
    int? offset,
    String? error,
  }) {
    return TransactionListState(
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      error: error ?? this.error,
    );
  }
}

class TransactionListNotifier extends StateNotifier<TransactionListState> {
  final Ref _ref;
  static const int _pageSize = 30;

  TransactionListNotifier(this._ref) : super(const TransactionListState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null, offset: 0, hasMore: true);
    try {
      final repo = _ref.read(transactionRepositoryProvider);
      final results = await repo.getTransactionsPaginated(
        limit: _pageSize,
        offset: 0,
        queryFilter: state.filter,
      );

      state = state.copyWith(
        transactions: results,
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
      final repo = _ref.read(transactionRepositoryProvider);
      final results = await repo.getTransactionsPaginated(
        limit: _pageSize,
        offset: state.offset,
        queryFilter: state.filter,
      );

      state = state.copyWith(
        transactions: [...state.transactions, ...results],
        isLoadMore: false,
        hasMore: results.length >= _pageSize,
        offset: state.offset + results.length,
      );
    } catch (e) {
      state = state.copyWith(isLoadMore: false, error: e.toString());
    }
  }

  void updateFilter(TransactionQueryFilter newFilter) {
    state = state.copyWith(filter: newFilter);
    loadInitial();
  }

  void updateQuery(String query) {
    if (state.filter.query == query) return;
    updateFilter(state.filter.copyWith(query: query));
  }

  void toggleCategory(String category) {
    final currentCategories = List<String>.from(state.filter.categories);
    if (currentCategories.contains(category)) {
      currentCategories.remove(category);
    } else {
      currentCategories.add(category);
    }
    updateFilter(state.filter.copyWith(categories: currentCategories));
  }

  void setSortBy(String sortBy) {
    updateFilter(state.filter.copyWith(sortBy: sortBy));
  }

  void resetFilters() {
    updateFilter(const TransactionQueryFilter());
  }

  Future<void> refresh() async {
    // Triggers a network pull-to-refresh if desired, then reloads local
    await loadInitial();
  }
}

final transactionListProvider =
    StateNotifierProvider<TransactionListNotifier, TransactionListState>((ref) {
  return TransactionListNotifier(ref);
});
