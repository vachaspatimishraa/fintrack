import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationState {
  final int limit;
  final int page;

  const PaginationState({
    this.limit = 20,
    this.page = 0,
  });

  PaginationState copyWith({
    int? limit,
    int? page,
  }) {
    return PaginationState(
      limit: limit ?? this.limit,
      page: page ?? this.page,
    );
  }
}

class AccountPaginationNotifier extends StateNotifier<PaginationState> {
  AccountPaginationNotifier() : super(const PaginationState());

  void setPage(int page) {
    if (page >= 0) {
      state = state.copyWith(page: page);
    }
  }

  void setLimit(int limit) {
    if (limit > 0) {
      state = state.copyWith(limit: limit, page: 0); // reset page on limit change
    }
  }

  void nextPage() {
    state = state.copyWith(page: state.page + 1);
  }

  void previousPage() {
    if (state.page > 0) {
      state = state.copyWith(page: state.page - 1);
    }
  }

  void reset() {
    state = const PaginationState();
  }
}

final accountPaginationProvider = StateNotifierProvider<AccountPaginationNotifier, PaginationState>((ref) {
  return AccountPaginationNotifier();
});
