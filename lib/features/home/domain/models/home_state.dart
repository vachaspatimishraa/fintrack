import 'package:flutter/material.dart';
import 'dashboard_model.dart';

class HomeState {
  final bool isLoading;
  final String? error;
  final DashboardModel? dashboard;
  final DateTimeRange? selectedDateRange;
  final String? selectedTypeFilter; // 'income', 'expense', or null
  final String? selectedCategoryFilter; // or null

  const HomeState({
    this.isLoading = false,
    this.error,
    this.dashboard,
    this.selectedDateRange,
    this.selectedTypeFilter,
    this.selectedCategoryFilter,
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    DashboardModel? dashboard,
    DateTimeRange? selectedDateRange,
    String? selectedTypeFilter,
    String? selectedCategoryFilter,
    bool clearError = false,
    bool clearDateRange = false,
    bool clearTypeFilter = false,
    bool clearCategoryFilter = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      dashboard: dashboard ?? this.dashboard,
      selectedDateRange: clearDateRange ? null : (selectedDateRange ?? this.selectedDateRange),
      selectedTypeFilter: clearTypeFilter ? null : (selectedTypeFilter ?? this.selectedTypeFilter),
      selectedCategoryFilter: clearCategoryFilter ? null : (selectedCategoryFilter ?? this.selectedCategoryFilter),
    );
  }
}
