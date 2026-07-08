import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../splash/providers/initialization_provider.dart';
import '../../sync/providers/sync_provider.dart';
import '../data/datasources/local/budget_local_datasource.dart';
import '../data/datasources/remote/budget_remote_datasource.dart';
import '../data/repositories/budget_repository_impl.dart';
import '../domain/entities/budget_entity.dart';
import '../domain/entities/budget_alert_entity.dart';
import '../domain/repositories/budget_repository.dart';

import '../domain/repositories/budget_alert_repository.dart';
import '../data/repositories/budget_alert_repository_impl.dart';
import '../data/datasources/local/budget_alert_local_datasource.dart';
import '../domain/utils/budget_dashboard_engine.dart';
import '../domain/entities/budget_dashboard_data.dart';
import 'budget_analytics_provider.dart';

final budgetLocalDatasourceProvider = Provider<BudgetLocalDatasource>((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  return BudgetLocalDatasource(isarService.isar);
});

final budgetRemoteDatasourceProvider = Provider<BudgetRemoteDataSource>((ref) {
  final supabase = Supabase.instance.client;
  return BudgetRemoteDataSource(supabase);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final localDatasource = ref.watch(budgetLocalDatasourceProvider);
  final remoteDatasource = ref.watch(budgetRemoteDatasourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final supabase = Supabase.instance.client;
  final isarService = ref.watch(isarInitializationServiceProvider);
  return BudgetRepositoryImpl(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    syncService: syncService,
    supabase: supabase,
    isar: isarService.isar,
  );
});

final budgetsStreamProvider = StreamProvider<List<BudgetEntity>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.watchBudgets();
});

final budgetDashboardEngineProvider = Provider<BudgetDashboardEngine>((ref) {
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final alertRepo = ref.watch(budgetAlertRepositoryProvider);
  final analyticsRepo = ref.watch(budgetAnalyticsRepositoryProvider);
  return BudgetDashboardEngine(
    budgetRepository: budgetRepo,
    alertRepository: alertRepo,
    analyticsRepository: analyticsRepo,
  );
});

final budgetDashboardProvider = FutureProvider<BudgetDashboardData>((ref) {
  final engine = ref.watch(budgetDashboardEngineProvider);
  // Listen to streams to trigger refresh when data changes
  ref.watch(budgetsStreamProvider);
  ref.watch(activeAlertsStreamProvider);
  
  return engine.getDashboardData();
});

final budgetAlertRepositoryProvider = Provider<BudgetAlertRepository>((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  return BudgetAlertRepositoryImpl(BudgetAlertLocalDatasource(isarService.isar));
});

final activeAlertsStreamProvider = StreamProvider<List<BudgetAlertEntity>>((ref) {
  final repository = ref.watch(budgetAlertRepositoryProvider);
  return repository.watchActiveAlerts();
});

final alertHistoryStreamProvider = StreamProvider<List<BudgetAlertEntity>>((ref) {
  final repository = ref.watch(budgetAlertRepositoryProvider);
  return repository.watchAlertHistory();
});

final watchBudgetProvider = StreamProvider.family<BudgetEntity?, String>((ref, uuid) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.watchBudget(uuid);
});

final categoryBudgetsProvider = Provider<List<BudgetEntity>>((ref) {
  final budgetsAsync = ref.watch(budgetsStreamProvider);
  return budgetsAsync.maybeWhen(
    data: (budgets) => budgets.where((b) => b.budgetType == 'category').toList(),
    orElse: () => [],
  );
});

final categoryBudgetStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final categoryBudgets = ref.watch(categoryBudgetsProvider);
  double totalAllocated = 0;
  double totalSpent = 0;
  for (final b in categoryBudgets) {
    totalAllocated += b.amount;
    totalSpent += b.spentAmount;
  }
  return {
    'totalAllocated': totalAllocated,
    'totalSpent': totalSpent,
    'count': categoryBudgets.length,
  };
});
