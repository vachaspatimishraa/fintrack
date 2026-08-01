import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../splash/providers/initialization_provider.dart';
import '../../sync/providers/sync_provider.dart';
import '../data/repositories/goal_repository_impl.dart';
import '../data/datasources/local/goals_local_datasource_impl.dart';
import '../data/datasources/remote/goals_remote_datasource_impl.dart';
import '../domain/entities/goal_entity.dart';
import '../domain/entities/goal_progress_model.dart';
import '../domain/entities/goal_forecast_model.dart';
import '../domain/entities/goal_analytics_model.dart';
import '../domain/entities/goal_template_model.dart';
import '../domain/entities/goal_sync_status.dart';
import '../domain/repositories/goal_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final goalLocalDatasourceProvider = Provider((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  return GoalsLocalDatasourceImpl(isarService.isar);
});

final goalRemoteDatasourceProvider = Provider((ref) {
  final supabase = Supabase.instance.client;
  return GoalsRemoteDatasourceImpl(supabase);
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final localDatasource = ref.watch(goalLocalDatasourceProvider);
  final remoteDatasource = ref.watch(goalRemoteDatasourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final supabase = Supabase.instance.client;
  return GoalRepositoryImpl(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    supabase: supabase,
    syncService: syncService,
  );
});

final goalsStreamProvider = StreamProvider<List<GoalEntity>>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.watchGoals();
});

final activeGoalsProvider = Provider<List<GoalEntity>>((ref) {
  final goalsAsync = ref.watch(goalsStreamProvider);
  return goalsAsync.maybeWhen(
    data: (goals) => goals.where((g) => g.status == 'active').toList(),
    orElse: () => [],
  );
});

final completedGoalsProvider = Provider<List<GoalEntity>>((ref) {
  final goalsAsync = ref.watch(goalsStreamProvider);
  return goalsAsync.maybeWhen(
    data: (goals) => goals.where((g) => g.status == 'completed').toList(),
    orElse: () => [],
  );
});

final goalDetailsProvider = FutureProvider.family<GoalEntity?, String>((ref, uuid) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.loadGoal(uuid);
});

final goalProgressProvider = FutureProvider.family<GoalProgressModel, String>((ref, uuid) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.calculateProgress(uuid);
});

final goalForecastProvider = FutureProvider.family<GoalForecastModel, String>((ref, uuid) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.forecastCompletion(uuid);
});

final goalAnalyticsProvider = FutureProvider.family<GoalAnalyticsModel, String>((ref, uuid) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.generateAnalytics(uuid);
});

final goalTemplateProvider = FutureProvider<List<GoalTemplateModel>>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.loadTemplates();
});

final goalSyncProvider = StreamProvider<GoalSyncStatus>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.watchSynchronization();
});
