class BudgetQueryFilter {
  final String query;
  final String? status;
  final String? categoryId;
  final String? accountId;
  final String? budgetType;
  final String sortBy; // name, newest, oldest, amount_high, amount_low, progress_high, progress_low

  const BudgetQueryFilter({
    this.query = '',
    this.status,
    this.categoryId,
    this.accountId,
    this.budgetType,
    this.sortBy = 'newest',
  });

  BudgetQueryFilter copyWith({
    String? query,
    String? status,
    bool clearStatus = false,
    String? categoryId,
    bool clearCategoryId = false,
    String? accountId,
    bool clearAccountId = false,
    String? budgetType,
    bool clearBudgetType = false,
    String? sortBy,
  }) {
    return BudgetQueryFilter(
      query: query ?? this.query,
      status: clearStatus ? null : (status ?? this.status),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      budgetType: clearBudgetType ? null : (budgetType ?? this.budgetType),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
