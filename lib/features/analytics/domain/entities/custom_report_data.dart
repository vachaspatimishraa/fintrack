import '../../../transactions/domain/entities/transaction_entity.dart';

class CustomReportFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> selectedAccounts;
  final List<String> selectedCategories;
  final List<String> selectedTypes; // income, expense, transfer, adjustment, refund
  final double? minAmount;
  final double? maxAmount;
  final String searchQuery;
  final String? paymentMethod;

  const CustomReportFilter({
    this.startDate,
    this.endDate,
    this.selectedAccounts = const [],
    this.selectedCategories = const [],
    this.selectedTypes = const [],
    this.minAmount,
    this.maxAmount,
    this.searchQuery = '',
    this.paymentMethod,
  });

  factory CustomReportFilter.empty() => const CustomReportFilter();

  CustomReportFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? selectedAccounts,
    List<String>? selectedCategories,
    List<String>? selectedTypes,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    String? paymentMethod,
  }) {
    return CustomReportFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedAccounts: selectedAccounts ?? this.selectedAccounts,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      searchQuery: searchQuery ?? this.searchQuery,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class CustomReportConfig {
  final String uuid;
  final String name;
  final CustomReportFilter filter;
  final String groupBy; // day, week, month, quarter, year, category, account, budget
  final String sortBy; // newest, oldest, highestAmount, lowestAmount, category, account
  final String chartType; // line, bar, pie, area, progress
  final DateTime createdAt;

  const CustomReportConfig({
    required this.uuid,
    required this.name,
    required this.filter,
    required this.groupBy,
    required this.sortBy,
    required this.chartType,
    required this.createdAt,
  });
}

class CustomReportStats {
  final double income;
  final double expense;
  final double savings;
  final double cashFlow;
  final double averageTransaction;
  final double largestTransaction;
  final int transactionCount;
  final double budgetUtilization;
  final double complianceScore;

  const CustomReportStats({
    required this.income,
    required this.expense,
    required this.savings,
    required this.cashFlow,
    required this.averageTransaction,
    required this.largestTransaction,
    required this.transactionCount,
    required this.budgetUtilization,
    required this.complianceScore,
  });

  factory CustomReportStats.zero() => const CustomReportStats(
        income: 0.0,
        expense: 0.0,
        savings: 0.0,
        cashFlow: 0.0,
        averageTransaction: 0.0,
        largestTransaction: 0.0,
        transactionCount: 0,
        budgetUtilization: 0.0,
        complianceScore: 100.0,
      );
}

class CustomReportGroup {
  final String name;
  final double income;
  final double expense;
  final double savings;
  final int transactionCount;

  const CustomReportGroup({
    required this.name,
    required this.income,
    required this.expense,
    required this.savings,
    required this.transactionCount,
  });
}

class CustomReportDataset {
  final CustomReportFilter filter;
  final CustomReportStats stats;
  final List<TransactionEntity> transactions;
  final List<CustomReportGroup> groups;
  final bool isEmpty;

  const CustomReportDataset({
    required this.filter,
    required this.stats,
    required this.transactions,
    required this.groups,
    this.isEmpty = false,
  });

  factory CustomReportDataset.empty() => CustomReportDataset(
        filter: CustomReportFilter.empty(),
        stats: CustomReportStats.zero(),
        transactions: const [],
        groups: const [],
        isEmpty: true,
      );
}
