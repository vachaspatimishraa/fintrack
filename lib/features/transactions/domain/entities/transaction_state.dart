import 'package:flutter/material.dart';
import 'transaction_entity.dart';

class TransactionState {
  final List<TransactionEntity> transactions;
  final bool isLoading;
  final String? errorMessage;
  final TransactionFilters filters;

  const TransactionState({
    required this.transactions,
    this.isLoading = false,
    this.errorMessage,
    this.filters = const TransactionFilters(),
  });

  TransactionState copyWith({
    List<TransactionEntity>? transactions,
    bool? isLoading,
    String? errorMessage,
    TransactionFilters? filters,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      filters: filters ?? this.filters,
    );
  }
}

class TransactionFilters {
  final String query;
  final String? type;
  final String? categoryId;
  final String? category;
  final String? accountId;
  final DateTimeRange? dateRange;

  const TransactionFilters({
    this.query = '',
    this.type,
    this.categoryId,
    this.category,
    this.accountId,
    this.dateRange,
  });

  TransactionFilters copyWith({
    String? query,
    String? type,
    String? categoryId,
    String? category,
    String? accountId,
    DateTimeRange? dateRange,
    bool clearType = false,
    bool clearCategoryId = false,
    bool clearCategory = false,
    bool clearAccountId = false,
    bool clearDateRange = false,
  }) {
    return TransactionFilters(
      query: query ?? this.query,
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      category: clearCategory ? null : (category ?? this.category),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }
}
