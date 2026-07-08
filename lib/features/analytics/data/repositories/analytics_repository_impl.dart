import 'dart:async';
import '../../../budget/domain/repositories/budget_repository.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../budget/domain/entities/budget_entity.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/analytics_state.dart';
import '../../domain/entities/monthly_report_data.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/utils/analytics_engine.dart';
import '../../domain/utils/monthly_aggregator.dart';

import '../../domain/entities/yearly_report_data.dart';
import '../../domain/utils/yearly_aggregator.dart';
import '../../domain/entities/custom_report_data.dart';
import '../../domain/utils/custom_report_engine.dart';
import '../../domain/entities/financial_health_data.dart';
import '../../domain/utils/financial_health_engine.dart';
import '../../domain/entities/ai_insight_data.dart';
import '../../domain/utils/ai_insight_engine.dart';
import '../datasources/repository_cache.dart';




class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;
  final List<CustomReportConfig> _savedReports = [];
  final List<AIInsight> _historyInsights = [];
  final StreamController<List<CustomReportConfig>> _customReportsController = StreamController<List<CustomReportConfig>>.broadcast();
  final RepositoryCache _cache = RepositoryCache();



  AnalyticsRepositoryImpl(this._transactionRepository, this._budgetRepository) {
    // Populate presets
    _savedReports.addAll([
      CustomReportConfig(
        uuid: 'preset-high-spending',
        name: 'High Spending Report',
        filter: const CustomReportFilter(minAmount: 5000.0),
        groupBy: 'category',
        sortBy: 'highestAmount',
        chartType: 'bar',
        createdAt: DateTime.now(),
      ),
      CustomReportConfig(
        uuid: 'preset-food-analysis',
        name: 'Food Spending Analysis',
        filter: const CustomReportFilter(selectedCategories: ['Food']),
        groupBy: 'month',
        sortBy: 'newest',
        chartType: 'line',
        createdAt: DateTime.now(),
      ),
      CustomReportConfig(
        uuid: 'preset-salary-report',
        name: 'Salary & Income Tracking',
        filter: const CustomReportFilter(selectedTypes: ['income']),
        groupBy: 'month',
        sortBy: 'newest',
        chartType: 'line',
        createdAt: DateTime.now(),
      ),
    ]);
    _customReportsController.add(List.unmodifiable(_savedReports));

    // Clear cache reactively on database updates
    _transactionRepository.watchTransactions().listen((_) => _cache.clear());
    _budgetRepository.watchBudgets().listen((_) => _cache.clear());
  }

  @override
  Future<AnalyticsState> getAnalyticsState() async {
    final list = await _transactionRepository.getTransactions();
    return AnalyticsEngine.calculateState(list);
  }

  @override
  Stream<AnalyticsState> watchAnalyticsState() {
    return _transactionRepository.watchTransactions().map((list) {
      return AnalyticsEngine.calculateState(list);
    });
  }

  @override
  Future<MonthlyReport> getMonthlyReport(DateTime monthAnchor) async {
    final key = 'monthly-${monthAnchor.year}-${monthAnchor.month}';
    final cached = _cache.get<MonthlyReport>(key);
    if (cached != null) return cached;

    final transactions = await _transactionRepository.getTransactions();
    final budgets = await _budgetRepository.getActiveBudgets();
    final report = MonthlyAggregator.aggregate(
      transactions: transactions,
      budgets: budgets,
      monthAnchor: monthAnchor,
    );
    _cache.put(key, report);
    return report;
  }

  @override
  Future<MonthlySummary> getMonthlySummary(DateTime monthAnchor) async {
    final report = await getMonthlyReport(monthAnchor);
    return report.summary;
  }

  @override
  Future<MonthlyStatistics> getMonthlyStatistics(DateTime monthAnchor) async {
    final report = await getMonthlyReport(monthAnchor);
    return report.statistics;
  }

  @override
  Future<MonthlyBudgetProgress> getMonthlyBudget(DateTime monthAnchor) async {
    final report = await getMonthlyReport(monthAnchor);
    return report.budgetProgress;
  }

  @override
  Future<List<MonthlyCategoryBreakdown>> getMonthlyCategories(DateTime monthAnchor) async {
    final report = await getMonthlyReport(monthAnchor);
    return report.categories;
  }

  @override
  Future<MonthlyComparison> getMonthlyComparison(DateTime monthAnchor) async {
    final report = await getMonthlyReport(monthAnchor);
    return report.comparison;
  }

  @override
  Future<MonthlyScore> getMonthlyFinancialScore(DateTime monthAnchor) async {
    final report = await getMonthlyReport(monthAnchor);
    return report.score;
  }

  @override
  Stream<MonthlyReport> watchMonthlyReports(DateTime monthAnchor) {
    final controller = StreamController<MonthlyReport>();
    List<TransactionEntity>? lastTx;
    List<BudgetEntity>? lastBudgets;

    void emit() {
      if (lastTx != null && lastBudgets != null) {
        try {
          final report = MonthlyAggregator.aggregate(
            transactions: lastTx!,
            budgets: lastBudgets!,
            monthAnchor: monthAnchor,
          );
          if (!controller.isClosed) {
            controller.add(report);
          }
        } catch (e, stack) {
          if (!controller.isClosed) {
            controller.addError(e, stack);
          }
        }
      }
    }

    final txSub = _transactionRepository.watchTransactions().listen(
      (txs) {
        lastTx = txs;
        emit();
      },
      onError: (err, stack) {
        if (!controller.isClosed) {
          controller.addError(err, stack);
        }
      },
    );

    final budgetSub = _budgetRepository.watchBudgets().listen(
      (bgts) {
        lastBudgets = bgts;
        emit();
      },
      onError: (err, stack) {
        if (!controller.isClosed) {
          controller.addError(err, stack);
        }
      },
    );

    controller.onCancel = () {
      txSub.cancel();
      budgetSub.cancel();
    };

    return controller.stream;
  }

  @override
  Future<YearlyReport> getYearlyReport(DateTime yearAnchor) async {
    final key = 'yearly-${yearAnchor.year}';
    final cached = _cache.get<YearlyReport>(key);
    if (cached != null) return cached;

    final transactions = await _transactionRepository.getTransactions();
    final budgets = await _budgetRepository.getActiveBudgets();
    final report = YearlyAggregator.aggregate(
      transactions: transactions,
      budgets: budgets,
      yearAnchor: yearAnchor,
    );
    _cache.put(key, report);
    return report;
  }

  @override
  Future<YearlySummary> getYearlySummary(DateTime yearAnchor) async {
    final report = await getYearlyReport(yearAnchor);
    return report.summary;
  }

  @override
  Future<YearlyStatistics> getYearlyStatistics(DateTime yearAnchor) async {
    final report = await getYearlyReport(yearAnchor);
    return report.statistics;
  }

  @override
  Future<YearlyBudgetProgress> getYearlyBudget(DateTime yearAnchor) async {
    final report = await getYearlyReport(yearAnchor);
    return report.budgetProgress;
  }

  @override
  Future<List<YearlyCategoryBreakdown>> getYearlyCategories(DateTime yearAnchor) async {
    final report = await getYearlyReport(yearAnchor);
    return report.categories;
  }

  @override
  Future<YearlyComparison> getYearComparison(DateTime yearAnchor) async {
    final report = await getYearlyReport(yearAnchor);
    return report.comparison;
  }

  @override
  Future<YearlyHealth> getFinancialHealth(DateTime yearAnchor) async {
    final report = await getYearlyReport(yearAnchor);
    return report.health;
  }

  @override
  Stream<YearlyReport> watchYearlyReports(DateTime yearAnchor) {
    final controller = StreamController<YearlyReport>();
    List<TransactionEntity>? lastTx;
    List<BudgetEntity>? lastBudgets;

    void emit() {
      if (lastTx != null && lastBudgets != null) {
        try {
          final report = YearlyAggregator.aggregate(
            transactions: lastTx!,
            budgets: lastBudgets!,
            yearAnchor: yearAnchor,
          );
          if (!controller.isClosed) {
            controller.add(report);
          }
        } catch (e, stack) {
          if (!controller.isClosed) {
            controller.addError(e, stack);
          }
        }
      }
    }

    final txSub = _transactionRepository.watchTransactions().listen(
      (txs) {
        lastTx = txs;
        emit();
      },
      onError: (err, stack) {
        if (!controller.isClosed) {
          controller.addError(err, stack);
        }
      },
    );

    final budgetSub = _budgetRepository.watchBudgets().listen(
      (bgts) {
        lastBudgets = bgts;
        emit();
      },
      onError: (err, stack) {
        if (!controller.isClosed) {
          controller.addError(err, stack);
        }
      },
    );

    controller.onCancel = () {
      txSub.cancel();
      budgetSub.cancel();
    };

    return controller.stream;
  }

  @override
  Future<CustomReportDataset> generateCustomReport(CustomReportFilter filter, String groupBy, String sortBy) async {
    final transactions = await _transactionRepository.getTransactions();
    return CustomReportEngine.generate(
      transactions: transactions,
      filter: filter,
      groupBy: groupBy,
      sortBy: sortBy,
    );
  }

  @override
  Future<CustomReportDataset> previewCustomReport(CustomReportFilter filter) async {
    return generateCustomReport(filter, 'category', 'newest');
  }

  @override
  Future<void> saveCustomReport(CustomReportConfig config) async {
    _savedReports.removeWhere((r) => r.uuid == config.uuid);
    _savedReports.add(config);
    _customReportsController.add(List.unmodifiable(_savedReports));
  }

  @override
  Future<void> deleteCustomReport(String uuid) async {
    _savedReports.removeWhere((r) => r.uuid == uuid);
    _customReportsController.add(List.unmodifiable(_savedReports));
  }

  @override
  Future<List<CustomReportConfig>> loadSavedReports() async {
    return List.unmodifiable(_savedReports);
  }

  @override
  Stream<List<CustomReportConfig>> watchCustomReports() {
    // Return a stream that starts with current list, then yields changes
    final controller = StreamController<List<CustomReportConfig>>();
    controller.add(List.unmodifiable(_savedReports));
    final sub = _customReportsController.stream.listen(controller.add);
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  @override
  Future<FinancialHealthReport> calculateFinancialHealth() async {
    const key = 'financial-health';
    final cached = _cache.get<FinancialHealthReport>(key);
    if (cached != null) return cached;

    final transactions = await _transactionRepository.getTransactions();
    final budgets = await _budgetRepository.getActiveBudgets();
    final report = FinancialHealthEngine.evaluate(
      transactions: transactions,
      budgets: budgets,
    );
    _cache.put(key, report);
    return report;
  }

  @override
  Stream<FinancialHealthReport> watchFinancialHealthReport() {
    final controller = StreamController<FinancialHealthReport>();
    List<TransactionEntity>? lastTx;
    List<BudgetEntity>? lastBudgets;

    void emit() {
      if (lastTx != null && lastBudgets != null) {
        try {
          final report = FinancialHealthEngine.evaluate(
            transactions: lastTx!,
            budgets: lastBudgets!,
          );
          if (!controller.isClosed) {
            controller.add(report);
          }
        } catch (e, stack) {
          if (!controller.isClosed) {
            controller.addError(e, stack);
          }
        }
      }
    }

    final txSub = _transactionRepository.watchTransactions().listen(
      (txs) {
        lastTx = txs;
        emit();
      },
      onError: (err, stack) {
        if (!controller.isClosed) {
          controller.addError(err, stack);
        }
      },
    );

    final budgetSub = _budgetRepository.watchBudgets().listen(
      (bgts) {
        lastBudgets = bgts;
        emit();
      },
      onError: (err, stack) {
        if (!controller.isClosed) {
          controller.addError(err, stack);
        }
      },
    );

    controller.onCancel = () {
      txSub.cancel();
      budgetSub.cancel();
    };

    return controller.stream;
  }

  @override
  Future<AIInsightsReport> generateAIInsights() async {
    const key = 'ai-insights';
    final cached = _cache.get<AIInsightsReport>(key);
    if (cached != null) return cached;

    final transactions = await _transactionRepository.getTransactions();
    final report = AIInsightEngine.generate(transactions: transactions);
    if (report.isEmpty) return report;

    // Apply history overlays (pinned/dismissed states)
    final overlays = <AIInsight>[];
    for (final insight in report.currentInsights) {
      final match = _historyInsights.firstWhere(
        (h) => h.id == insight.id,
        orElse: () => insight,
      );
      // Only keep in currentInsights if not dismissed
      if (!match.dismissed) {
        overlays.add(match);
      }
    }

    final cachedReport = AIInsightsReport(
      currentInsights: overlays,
      forecast: report.forecast,
      detectedPatterns: report.detectedPatterns,
      isEmpty: false,
    );
    _cache.put(key, cachedReport);
    return cachedReport;
  }

  @override
  Stream<AIInsightsReport> watchAIInsights() {
    final controller = StreamController<AIInsightsReport>();
    List<TransactionEntity>? lastTx;

    void emit() {
      if (lastTx != null) {
        try {
          final report = AIInsightEngine.generate(transactions: lastTx!);
          final overlays = <AIInsight>[];
          for (final insight in report.currentInsights) {
            final match = _historyInsights.firstWhere(
              (h) => h.id == insight.id,
              orElse: () => insight,
            );
            if (!match.dismissed) {
              overlays.add(match);
            }
          }
          if (!controller.isClosed) {
            controller.add(
              AIInsightsReport(
                currentInsights: overlays,
                forecast: report.forecast,
                detectedPatterns: report.detectedPatterns,
                isEmpty: false,
              ),
            );
          }
        } catch (e, stack) {
          if (!controller.isClosed) {
            controller.addError(e, stack);
          }
        }
      }
    }

    final txSub = _transactionRepository.watchTransactions().listen(
      (txs) {
        lastTx = txs;
        emit();
      },
      onError: (err, stack) {
        if (!controller.isClosed) {
          controller.addError(err, stack);
        }
      },
    );

    controller.onCancel = () {
      txSub.cancel();
    };

    return controller.stream;
  }

  @override
  Future<List<AIInsight>> getInsightHistory() async {
    return List.unmodifiable(_historyInsights);
  }

  @override
  Future<void> dismissInsight(String id) async {
    final index = _historyInsights.indexWhere((h) => h.id == id);
    if (index >= 0) {
      _historyInsights[index] = _historyInsights[index].copyWith(dismissed: true);
    } else {
      // Find inside current generated to persist to history
      final report = await generateAIInsights();
      final match = report.currentInsights.firstWhere((i) => i.id == id, orElse: () => _defaultInsight(id));
      _historyInsights.add(match.copyWith(dismissed: true));
    }
  }

  @override
  Future<void> pinInsight(String id) async {
    final index = _historyInsights.indexWhere((h) => h.id == id);
    if (index >= 0) {
      final currentPinned = _historyInsights[index].pinned;
      _historyInsights[index] = _historyInsights[index].copyWith(pinned: !currentPinned);
    } else {
      final report = await generateAIInsights();
      final match = report.currentInsights.firstWhere((i) => i.id == id, orElse: () => _defaultInsight(id));
      _historyInsights.add(match.copyWith(pinned: true));
    }
  }

  AIInsight _defaultInsight(String id) {
    return AIInsight(
      id: id,
      title: 'Insight',
      description: '',
      category: 'General',
      severity: 'Positive',
      confidence: 1.0,
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
  }

  @override
  Future<void> refreshAnalytics() async {
    _cache.clear();
  }
}



