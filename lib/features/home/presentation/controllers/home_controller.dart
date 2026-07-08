import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_provider.dart';
import '../../../accounts/providers/account_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/excel_service.dart';

class HomeController {
  final Ref _ref;

  HomeController(this._ref);

  void switchAccount(String uuid) {
    _ref.read(currentAccountProvider.notifier).selectAccount(uuid);
  }

  void setFilterPeriod(String period) {
    final notifier = _ref.read(homeStateProvider.notifier);
    final range = notifier.getRangeForPeriod(period);
    notifier.setDateRange(range);
  }

  void setCustomDateRange(DateTimeRange range) {
    _ref.read(homeStateProvider.notifier).setDateRange(range);
  }

  void setTypeFilter(String? type) {
    _ref.read(homeStateProvider.notifier).setTypeFilter(type);
  }

  void setCategoryFilter(String? category) {
    _ref.read(homeStateProvider.notifier).setCategoryFilter(category);
  }

  void clearFilters() {
    final notifier = _ref.read(homeStateProvider.notifier);
    notifier.setDateRange(null);
    notifier.setTypeFilter(null);
    notifier.setCategoryFilter(null);
  }

  Future<void> refreshDashboard() async {
    await _ref.read(homeStateProvider.notifier).refreshDashboard();
  }

  Future<void> exportPdf(List<TransactionEntity> transactions, String accountName) async {
    final pdfService = PdfService();
    await pdfService.exportTransactions(transactions, 'Report: $accountName');
  }

  Future<void> exportExcel(List<TransactionEntity> transactions) async {
    final excelService = ExcelService();
    await excelService.exportTransactions(transactions);
  }
}

final homeControllerProvider = Provider<HomeController>((ref) {
  return HomeController(ref);
});
