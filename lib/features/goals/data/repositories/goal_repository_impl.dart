import 'dart:async';
import '../../../../core/services/sync_service.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../domain/entities/contribution_entity.dart';
import '../../domain/entities/goal_progress_model.dart';
import '../../domain/entities/goal_forecast_model.dart';
import '../../domain/entities/goal_analytics_model.dart';
import '../../domain/entities/goal_reminder_model.dart';
import '../../domain/entities/goal_template_model.dart';
import '../../domain/entities/goal_sync_status.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/repositories/goals_local_datasource.dart';
import '../../domain/repositories/goals_remote_datasource.dart';
import '../../domain/utils/goals_performance_service.dart';
import '../../domain/services/goal_progress_service.dart';
import '../../domain/services/goal_forecast_service.dart';
import '../../domain/services/goal_analytics_service.dart';
import '../mappers/goal_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalsLocalDatasource _localDatasource;
  final GoalsRemoteDatasource _remoteDatasource;
  final SupabaseClient _supabase;
  final SyncService? _syncService;

  // Optimized In-Memory Cache
  final Map<String, GoalEntity> _goalCache = {};
  List<GoalEntity>? _cachedGoalList;
  DateTime? _lastFetchTime;

  GoalRepositoryImpl({
    required GoalsLocalDatasource localDatasource,
    required GoalsRemoteDatasource remoteDatasource,
    required SupabaseClient supabase,
    SyncService? syncService,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _supabase = supabase,
        _syncService = syncService;

  String get _currentUserId => _supabase.auth.currentUser?.id ?? '';

  void _invalidateCache() {
    _goalCache.clear();
    _cachedGoalList = null;
    _lastFetchTime = null;
  }

  @override
  Future<List<GoalEntity>> loadGoals() async {
    return getGoals();
  }

  Future<List<GoalEntity>> getGoals({bool includeDeleted = false}) async {
    if (_cachedGoalList != null && _lastFetchTime != null) {
      if (DateTime.now().difference(_lastFetchTime!).inMinutes < 5) {
        return _cachedGoalList!;
      }
    }

    return GoalsPerformanceService.track('getGoals', () async {
      final models = await _localDatasource.loadGoals(_currentUserId);
      final entities = models
          .where((m) => includeDeleted || !m.isDeleted)
          .map((m) => GoalMapper.toEntity(m))
          .toList();
      
      _cachedGoalList = entities;
      _lastFetchTime = DateTime.now();
      for (var e in entities) {
        _goalCache[e.uuid] = e;
      }
      
      return entities;
    });
  }

  @override
  Stream<List<GoalEntity>> watchGoals() {
    return _localDatasource.watchGoals(_currentUserId).map(
          (models) => models
              .where((m) => !m.isDeleted)
              .map((m) => GoalMapper.toEntity(m))
              .toList(),
        );
  }

  @override
  Future<GoalEntity?> loadGoal(String goalId) async {
    if (_goalCache.containsKey(goalId)) return _goalCache[goalId];

    return GoalsPerformanceService.track('getGoalByUuid', () async {
      final model = await _localDatasource.findGoalByUuid(goalId);
      if (model != null) {
        final entity = GoalMapper.toEntity(model);
        _goalCache[goalId] = entity;
        return entity;
      }
      return null;
    });
  }

  Future<GoalEntity?> getGoalByUuid(String uuid) async {
    return loadGoal(uuid);
  }

  Future<void> createGoal(GoalEntity goal) async {
    return saveGoal(goal);
  }

  @override
  Future<void> saveGoal(GoalEntity goal) async {
    await GoalsPerformanceService.track('saveGoal', () async {
      final model = GoalMapper.toModel(goal);
      await _localDatasource.saveGoal(model);
      _invalidateCache();
    });
  }

  Future<void> updateGoal(GoalEntity goal) async {
    return saveGoal(goal);
  }

  @override
  Future<void> archiveGoal(String goalId) async {
    final goal = await loadGoal(goalId);
    if (goal != null) {
      await updateGoal(goal.copyWith(status: 'archived', updatedAt: DateTime.now()));
    }
  }

  @override
  Future<void> restoreGoal(String goalId) async {
    final model = await _localDatasource.findGoalByUuid(goalId);
    if (model != null) {
      final restoredModel = GoalMapper.toModel(GoalMapper.toEntity(model).copyWith(
        isDeleted: false,
        updatedAt: DateTime.now(),
      ));
      await _localDatasource.saveGoal(restoredModel);
      _invalidateCache();
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await GoalsPerformanceService.track('deleteGoal', () async {
      await _localDatasource.deleteGoal(goalId);
      _invalidateCache();
      if (_syncService != null) {
        await _syncService!.queueSync(
          entityType: 'goal',
          entityUuid: goalId,
          action: 'delete',
          payload: {},
        );
      }
    });
  }

  // Milestone APIs
  @override
  Future<List<MilestoneEntity>> loadMilestones(String goalId) async {
    return []; // Placeholder for implementation
  }

  @override
  Future<void> addMilestone(MilestoneEntity milestone) async {}

  @override
  Future<void> updateMilestone(MilestoneEntity milestone) async {}

  @override
  Future<void> deleteMilestone(String milestoneId) async {}

  // Contribution APIs
  @override
  Future<void> addContribution(ContributionEntity contribution) async {}

  @override
  Future<List<ContributionEntity>> loadContributions(String goalId) async {
    return []; // Placeholder for implementation
  }

  @override
  Future<void> updateContribution(ContributionEntity contribution) async {}

  @override
  Future<void> deleteContribution(String contributionId) async {}

  // Progress & Forecast APIs
  @override
  Future<GoalProgressModel> calculateProgress(String goalId) async {
    return GoalProgressService(this).calculate(goalId);
  }

  @override
  Future<GoalForecastModel> forecastCompletion(String goalId) async {
    return GoalForecastService(this).generateForecast(goalId);
  }

  // Notification APIs
  @override
  Future<void> scheduleGoalReminder(GoalReminderModel reminder) async {}

  @override
  Future<void> cancelReminder(String reminderId) async {}

  @override
  Future<void> updateReminder(GoalReminderModel reminder) async {}

  @override
  Future<List<GoalReminderModel>> loadReminders() async {
    return [];
  }

  // Analytics APIs
  @override
  Future<GoalAnalyticsModel> generateAnalytics(String goalId) async {
    return GoalAnalyticsService(this).analyze(goalId);
  }

  @override
  Future<Map<String, dynamic>> generateSummary() async {
    return {};
  }

  // Template APIs
  @override
  Future<List<GoalTemplateModel>> loadTemplates() async {
    return [];
  }

  @override
  Future<void> createTemplate(GoalTemplateModel template) async {}

  @override
  Future<void> deleteTemplate(String templateId) async {}

  @override
  Future<void> applyTemplate(String templateId) async {}

  // Synchronization APIs
  @override
  Future<void> synchronizeGoals() async {
    await _remoteDatasource.synchronize();
  }

  @override
  Future<void> pauseSynchronization() async {}

  @override
  Future<void> resumeSynchronization() async {}

  @override
  Future<GoalSyncStatus> getSynchronizationStatus() async {
    return const GoalSyncStatus(isSyncing: false, pendingItems: 0);
  }

  @override
  Stream<GoalSyncStatus> watchSynchronization() {
    return Stream.value(const GoalSyncStatus(isSyncing: false, pendingItems: 0));
  }

  @override
  Future<void> synchronize() async {
    await synchronizeGoals();
  }
}
