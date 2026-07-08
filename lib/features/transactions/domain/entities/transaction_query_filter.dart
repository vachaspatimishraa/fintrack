import 'package:flutter/material.dart';

class TransactionQueryFilter {
  final String query;
  final String? type; // income, expense
  final List<String> categories;
  final String? accountId;
  final String? paymentMethod;
  final DateTimeRange? dateRange;
  final double? minAmount;
  final double? maxAmount;
  final String? amountComparison; // 'greater', 'less', 'between'
  final bool? hasReceipt; // true, false, null (all)
  final String? syncStatus; // 'all', 'pending', 'synced', 'failed'
  final bool? isDeleted;
  final bool? isRecurring;
  final String sortBy; // 'newest', 'oldest', 'highest_amount', 'lowest_amount', 'recently_updated', 'alphabetical', 'category'

  const TransactionQueryFilter({
    this.query = '',
    this.type,
    this.categories = const [],
    this.accountId,
    this.paymentMethod,
    this.dateRange,
    this.minAmount,
    this.maxAmount,
    this.amountComparison,
    this.hasReceipt,
    this.syncStatus,
    this.isDeleted = false,
    this.isRecurring,
    this.sortBy = 'newest',
  });

  TransactionQueryFilter copyWith({
    String? query,
    String? type,
    List<String>? categories,
    String? accountId,
    String? paymentMethod,
    DateTimeRange? dateRange,
    double? minAmount,
    double? maxAmount,
    String? amountComparison,
    bool? hasReceipt,
    String? syncStatus,
    bool? isDeleted,
    bool? isRecurring,
    String? sortBy,
  }) {
    return TransactionQueryFilter(
      query: query ?? this.query,
      type: type ?? this.type,
      categories: categories ?? this.categories,
      accountId: accountId ?? this.accountId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      dateRange: dateRange ?? this.dateRange,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      amountComparison: amountComparison ?? this.amountComparison,
      hasReceipt: hasReceipt ?? this.hasReceipt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      isRecurring: isRecurring ?? this.isRecurring,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
