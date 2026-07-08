import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/local/budget_local_datasource.dart';
import '../datasources/remote/budget_remote_datasource.dart';
import '../mappers/budget_mapper.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/entities/budget_event_bus.dart';
import '../../domain/entities/budget_statistics.dart';
import '../../domain/entities/budget_api_contract.dart';
import '../../domain/utils/budget_history_service.dart';
import '../../domain/utils/budget_alert_engine.dart';
import '../../domain/utils/budget_performance_service.dart';
import '../datasources/local/budget_alert_local_datasource.dart';
import '../repositories/budget_alert_repository_impl.dart';
import '../../../../core/database/isar/collections/budget_model.dart';
import '../../../../core/database/isar/collections/transaction_model.dart';
import '../../../../core/services/sync_service.dart';

/// Implementation of [BudgetRepository] following API contracts.
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDatasource _localDatasource;
  final BudgetRemoteDataSource _remoteDatasource;
  final SyncService _syncService;
  final SupabaseClient _supabase;
  final Isar _isar;
  final BudgetHistoryService _historyService;
  final BudgetAlertEngine _alertEngine;
  final BudgetEventBus _eventBus = BudgetEventBus();

  // Optimized Cache
  final Map<String, BudgetEntity> _budgetCache = {};
  BudgetStatistics? _cachedStats;
  DateTime? _lastStatsCalculation;

  BudgetRepositoryImpl({
    required BudgetLocalDatasource localDatasource,
    required BudgetRemoteDataSource remoteDatasource,
    required SyncService syncService,
    required SupabaseClient supabase,
    required Isar isar,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _syncService = syncService,
        _supabase = supabase,
        _isar = isar,
        _historyService = BudgetHistoryService(isar),
        _alertEngine = BudgetAlertEngine(BudgetAlertRepositoryImpl(BudgetAlertLocalDatasource(isar)));

  String get _currentUserId => _supabase.auth.currentUser?.id ?? '';

  void _invalidateCache() {
    _budgetCache.clear();
    _cachedStats = null;
    _lastStatsCalculation = null;
  }

  @override
  Future<void> createBudget(BudgetEntity budget) async {
    return BudgetPerformanceService.track('createBudget', () async {
      final newBudget = budget.copyWith(
        uuid: const Uuid().v4(),
        ownerId: _currentUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      await _saveBudgetInternal(newBudget, isNew: true);
    });
  }

  @override
  Future<void> updateBudget(BudgetEntity budget) async {
    return BudgetPerformanceService.track('updateBudget', () async {
      final updatedBudget = budget.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      await _saveBudgetInternal(updatedBudget, isNew: false);
    });
  }

  Future<void> _saveBudgetInternal(BudgetEntity budget, {required bool isNew}) async {
    final model = BudgetMapper.toModel(budget);
    if (isNew) {
      await _localDatasource.insert(model);
    } else {
      await _localDatasource.update(model);
    }
    
    _invalidateCache();
    _budgetCache[budget.uuid] = budget;

    await _historyService.recordAction(
      budgetUuid: model.uuid,
      action: isNew ? BudgetApiContract.opCreate : BudgetApiContract.opUpdate,
      newValue: model.toJson().toString(),
    );

    await _syncService.queueSync(
      entityType: 'budget',
      entityUuid: model.uuid,
      action: isNew ? BudgetApiContract.opCreate : BudgetApiContract.opUpdate,
      payload: model.toJson(),
    );

    _eventBus.publish(BudgetEvent(
      type: isNew ? BudgetEventType.budgetCreated : BudgetEventType.budgetUpdated,
      budgetUuid: model.uuid,
      payload: model.toJson(),
    ));
  }

  @override
  Future<void> deleteBudget(String uuid) async {
    return BudgetPerformanceService.track('deleteBudget', () async {
      await _localDatasource.delete(uuid);
      _invalidateCache();
      
      await _historyService.recordAction(
        budgetUuid: uuid,
        action: BudgetApiContract.opDelete,
      );

      await _syncService.queueSync(
        entityType: 'budget',
        entityUuid: uuid,
        action: BudgetApiContract.opDelete,
        payload: {},
      );

      _eventBus.publish(BudgetEvent(
        type: BudgetEventType.budgetDeleted,
        budgetUuid: uuid,
      ));
    });
  }

  @override
  Future<void> restoreBudget(String uuid) async {
    await _localDatasource.restore(uuid);
    _invalidateCache();

    await _syncService.queueSync(
      entityType: 'budget',
      entityUuid: uuid,
      action: BudgetApiContract.opRestore,
      payload: {},
    );

    _eventBus.publish(BudgetEvent(
      type: BudgetEventType.budgetRestored,
      budgetUuid: uuid,
    ));
  }

  @override
  Future<void> archiveBudget(String uuid) async {
    final model = await _localDatasource.findById(uuid);
    if (model != null) {
      model.status = BudgetApiContract.statusArchived;
      model.updatedAt = DateTime.now();
      model.syncStatus = 'pending';
      await _localDatasource.update(model);
      _invalidateCache();
      
      await _syncService.queueSync(
        entityType: 'budget',
        entityUuid: uuid,
        action: BudgetApiContract.opArchive,
        payload: model.toJson(),
      );

      _eventBus.publish(BudgetEvent(
        type: BudgetEventType.budgetUpdated,
        budgetUuid: uuid,
        payload: model.toJson(),
      ));
    }
  }

  @override
  Future<void> duplicateBudget(String uuid) async {
    final original = await getBudget(uuid);
    if (original != null) {
      final copy = original.copyWith(
        uuid: const Uuid().v4(),
        title: '${original.title} (Copy)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await createBudget(copy);
    }
  }

  @override
  Future<BudgetEntity?> getBudget(String uuid) async {
    if (_budgetCache.containsKey(uuid)) return _budgetCache[uuid];
    
    final model = await _localDatasource.findById(uuid);
    if (model != null) {
      final entity = BudgetMapper.toEntity(model);
      _budgetCache[uuid] = entity;
      return entity;
    }
    return null;
  }

  @override
  Stream<BudgetEntity?> watchBudget(String uuid) {
    return _isar.budgetModels
        .filter()
        .uuidEqualTo(uuid)
        .watch(fireImmediately: true)
        .map((models) => models.isEmpty ? null : BudgetMapper.toEntity(models.first));
  }

  @override
  Stream<List<BudgetEntity>> watchBudgets() {
    return _localDatasource.watch(_currentUserId).map(
          (models) => models.map((m) => BudgetMapper.toEntity(m)).toList(),
        );
  }

  @override
  Future<List<BudgetEntity>> getBudgets() async {
    final models = await _localDatasource.findAll(_currentUserId);
    return models.map((m) => BudgetMapper.toEntity(m)).toList();
  }

  @override
  Future<List<BudgetEntity>> getActiveBudgets() async {
    final models = await _localDatasource.findActive(_currentUserId);
    return models.map((m) => BudgetMapper.toEntity(m)).toList();
  }

  @override
  Future<List<BudgetEntity>> getCompletedBudgets() async {
    final models = await _localDatasource.getBudgetsByStatus(_currentUserId, BudgetApiContract.statusCompleted);
    return models.map((m) => BudgetMapper.toEntity(m)).toList();
  }

  @override
  Future<List<BudgetEntity>> getCategoryBudgets() async {
    final models = await _localDatasource.getCategoryBudgets(_currentUserId);
    return models.map((m) => BudgetMapper.toEntity(m)).toList();
  }

  @override
  Future<double> calculateProgress(String uuid) async {
    return BudgetPerformanceService.track('calculateProgress', () async {
      final budget = await _localDatasource.findById(uuid);
      if (budget == null) return 0.0;

      final spent = await _calculateSpentAmount(budget);
      final progress = budget.amount > 0 ? (spent / budget.amount) * 100 : 0.0;
      
      // Update local cache in DB
      budget.spentAmount = spent;
      budget.remainingAmount = budget.amount - spent;
      budget.progress = progress;
      
      if (progress >= 100) {
        budget.status = BudgetApiContract.statusExceeded;
      } else if (progress >= budget.alertThreshold) {
        budget.status = BudgetApiContract.statusWarning;
      } else {
        budget.status = BudgetApiContract.statusActive;
      }
      
      await _localDatasource.update(budget);
      _invalidateCache();
      
      // Check for alerts after updating progress
      await _alertEngine.checkBudget(BudgetMapper.toEntity(budget));

      return progress;
    });
  }

  @override
  Future<double> calculateRemaining(String uuid) async {
    final budget = await _localDatasource.findById(uuid);
    if (budget == null) return 0.0;
    final spent = await _calculateSpentAmount(budget);
    return budget.amount - spent;
  }

  Future<double> _calculateSpentAmount(BudgetModel budget) async {
    var query = _isar.transactionModels.filter()
        .userIdEqualTo(budget.ownerId)
        .isDeletedEqualTo(false)
        .typeEqualTo('expense')
        .dateBetween(budget.startDate, budget.endDate);

    if (budget.budgetType == 'category' && budget.categoryId != null) {
      query = query.categoryIdEqualTo(budget.categoryId!);
    }
    
    if (budget.accountId != null) {
      query = query.accountIdEqualTo(budget.accountId!);
    }

    final transactions = await query.findAll();
    return transactions.fold<double>(0.0, (double sum, tx) => sum + tx.amount);
  }

  @override
  Future<BudgetStatistics> calculateStatistics() async {
    // Check if we have valid cached stats (e.g. less than 1 minute old)
    if (_cachedStats != null && _lastStatsCalculation != null) {
      if (DateTime.now().difference(_lastStatsCalculation!).inSeconds < 60) {
        return _cachedStats!;
      }
    }

    return BudgetPerformanceService.track('calculateStatistics', () async {
      final budgets = await _localDatasource.findAll(_currentUserId);
      double totalBudget = 0;
      double totalSpent = 0;
      int activeCount = 0;
      int exceededCount = 0;
      int completedCount = 0;

      for (final b in budgets) {
        totalBudget += b.amount;
        totalSpent += b.spentAmount;
        if (b.status == BudgetApiContract.statusActive) activeCount++;
        if (b.status == BudgetApiContract.statusExceeded) exceededCount++;
        if (b.status == BudgetApiContract.statusCompleted) completedCount++;
      }

      final stats = BudgetStatistics(
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        remaining: totalBudget - totalSpent,
        overallProgress: totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0,
        activeBudgets: activeCount,
        completedBudgets: completedCount,
        exceededBudgets: exceededCount,
        averageBudget: budgets.isNotEmpty ? totalBudget / budgets.length : 0.0,
        averageSpending: budgets.isNotEmpty ? totalSpent / budgets.length : 0.0,
      );

      _cachedStats = stats;
      _lastStatsCalculation = DateTime.now();
      return stats;
    });
  }

  @override
  Future<void> refresh() async {
    return BudgetPerformanceService.track('refreshRepository', () async {
      final budgets = await _localDatasource.findAll(_currentUserId);
      for (final b in budgets) {
        await calculateProgress(b.uuid);
      }
      _invalidateCache();
    });
  }

  @override
  Future<void> sync() async {
    return synchronize();
  }

  Future<void> synchronize() async {
    return BudgetPerformanceService.track('syncBudgets', () async {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final remoteBudgets = await _remoteDatasource.download(userId);
      
      await _isar.writeTxn(() async {
        for (final remoteBudget in remoteBudgets) {
          final localModel = await _isar.budgetModels.filter().uuidEqualTo(remoteBudget.uuid).findFirst();
          
          if (localModel == null || remoteBudget.updatedAt.isAfter(localModel.updatedAt)) {
            final model = BudgetMapper.toModel(remoteBudget);
            model.syncStatus = 'synced';
            await _isar.budgetModels.put(model);
          }
        }
      });

      _invalidateCache();
      _eventBus.publish(const BudgetEvent(
        type: BudgetEventType.syncCompleted,
        budgetUuid: '',
      ));
    });
  }
}
