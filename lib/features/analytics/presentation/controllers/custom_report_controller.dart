import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/custom_report_data.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../providers/custom_report_provider.dart';

class CustomReportController {
  final AnalyticsRepository _repository;
  final Ref ref;

  CustomReportController(this._repository, this.ref);

  void updateDateRange(DateTime? start, DateTime? end) {
    final current = ref.read(customReportFilterProvider);
    ref.read(customReportFilterProvider.notifier).state = current.copyWith(
      startDate: start,
      endDate: end,
    );
  }

  void toggleCategory(String category) {
    final current = ref.read(customReportFilterProvider);
    final list = List<String>.from(current.selectedCategories);
    if (list.contains(category)) {
      list.remove(category);
    } else {
      list.add(category);
    }
    ref.read(customReportFilterProvider.notifier).state = current.copyWith(selectedCategories: list);
  }

  void updateCategories(List<String> categories) {
    final current = ref.read(customReportFilterProvider);
    ref.read(customReportFilterProvider.notifier).state = current.copyWith(selectedCategories: categories);
  }

  void toggleAccount(String accountId) {
    final current = ref.read(customReportFilterProvider);
    final list = List<String>.from(current.selectedAccounts);
    if (list.contains(accountId)) {
      list.remove(accountId);
    } else {
      list.add(accountId);
    }
    ref.read(customReportFilterProvider.notifier).state = current.copyWith(selectedAccounts: list);
  }

  void updateAccounts(List<String> accounts) {
    final current = ref.read(customReportFilterProvider);
    ref.read(customReportFilterProvider.notifier).state = current.copyWith(selectedAccounts: accounts);
  }

  void toggleType(String type) {
    final current = ref.read(customReportFilterProvider);
    final list = List<String>.from(current.selectedTypes);
    if (list.contains(type)) {
      list.remove(type);
    } else {
      list.add(type);
    }
    ref.read(customReportFilterProvider.notifier).state = current.copyWith(selectedTypes: list);
  }

  void updateAmountRange(double? min, double? max) {
    final current = ref.read(customReportFilterProvider);
    ref.read(customReportFilterProvider.notifier).state = current.copyWith(
      minAmount: min,
      maxAmount: max,
    );
  }

  void updateSearchQuery(String query) {
    final current = ref.read(customReportFilterProvider);
    ref.read(customReportFilterProvider.notifier).state = current.copyWith(searchQuery: query);
  }

  void clearFilters() {
    ref.read(customReportFilterProvider.notifier).state = CustomReportFilter.empty();
  }

  Future<void> saveReport(String name, String groupBy, String sortBy, String chartType) async {
    final filter = ref.read(customReportFilterProvider);
    final config = CustomReportConfig(
      uuid: const Uuid().v4(),
      name: name,
      filter: filter,
      groupBy: groupBy,
      sortBy: sortBy,
      chartType: chartType,
      createdAt: DateTime.now(),
    );
    await _repository.saveCustomReport(config);
  }

  Future<void> deleteReport(String uuid) async {
    await _repository.deleteCustomReport(uuid);
  }

  void loadPreset(CustomReportConfig config) {
    ref.read(customReportFilterProvider.notifier).state = config.filter;
    ref.read(customReportGroupByProvider.notifier).state = config.groupBy;
    ref.read(customReportSortByProvider.notifier).state = config.sortBy;
  }

  // Exports
  Future<bool> exportPDF(CustomReportDataset dataset) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> exportExcel(CustomReportDataset dataset) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> exportCSV(CustomReportDataset dataset) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> shareReport(CustomReportDataset dataset) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> printReport(CustomReportDataset dataset) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
