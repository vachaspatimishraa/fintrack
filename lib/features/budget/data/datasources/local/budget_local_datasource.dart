import 'package:isar/isar.dart';
import '../../../../../core/database/isar/collections/budget_model.dart';
import '../../../domain/entities/budget_api_contract.dart';

/// Contract-compliant local datasource for Budget entities.
class BudgetLocalDatasource {
  final Isar _isar;

  BudgetLocalDatasource(this._isar);

  /// Inserts a new budget record into Isar.
  Future<void> insert(BudgetModel budget) async {
    await _isar.writeTxn(() => _isar.budgetModels.put(budget));
  }

  /// Updates an existing budget record.
  Future<void> update(BudgetModel budget) async {
    await _isar.writeTxn(() => _isar.budgetModels.put(budget));
  }

  /// Soft-deletes a budget by its UUID.
  Future<void> delete(String uuid) async {
    final budget = await findById(uuid);
    if (budget != null) {
      await _isar.writeTxn(() async {
        budget.isDeleted = true;
        budget.deletedAt = DateTime.now();
        budget.syncStatus = 'pending';
        await _isar.budgetModels.put(budget);
      });
    }
  }

  /// Restores a soft-deleted budget.
  Future<void> restore(String uuid) async {
    final budget = await findById(uuid);
    if (budget != null) {
      await _isar.writeTxn(() async {
        budget.isDeleted = false;
        budget.deletedAt = null;
        budget.syncStatus = 'pending';
        budget.updatedAt = DateTime.now();
        await _isar.budgetModels.put(budget);
      });
    }
  }

  /// Finds a budget by its globally unique identifier.
  Future<BudgetModel?> findById(String uuid) {
    return _isar.budgetModels.filter().uuidEqualTo(uuid).findFirst();
  }

  /// Retrieves all non-deleted budgets for a user.
  Future<List<BudgetModel>> findAll(String? ownerId) async {
    var query = _isar.budgetModels.filter().isDeletedEqualTo(false);
    if (ownerId != null && ownerId.isNotEmpty) {
      query = query.ownerIdEqualTo(ownerId);
    } else {
      query = query.ownerIdEqualTo('');
    }
    return query.sortByStartDateDesc().findAll();
  }

  /// Finds active budgets (not archived or deleted).
  Future<List<BudgetModel>> findActive(String? ownerId) {
    var query = _isar.budgetModels.filter()
        .isDeletedEqualTo(false)
        .statusEqualTo(BudgetApiContract.statusActive);
    if (ownerId != null) query = query.ownerIdEqualTo(ownerId);
    return query.sortByStartDateDesc().findAll();
  }

  /// Finds archived budgets.
  Future<List<BudgetModel>> findArchived(String? ownerId) {
    var query = _isar.budgetModels.filter()
        .isDeletedEqualTo(false)
        .statusEqualTo(BudgetApiContract.statusArchived);
    if (ownerId != null) query = query.ownerIdEqualTo(ownerId);
    return query.sortByStartDateDesc().findAll();
  }

  /// Returns a reactive stream of all budgets.
  Stream<List<BudgetModel>> watch(String? ownerId) {
    var query = _isar.budgetModels.filter().isDeletedEqualTo(false);
    if (ownerId != null && ownerId.isNotEmpty) {
      query = query.ownerIdEqualTo(ownerId);
    } else {
      query = query.ownerIdEqualTo('');
    }
    return query.sortByStartDateDesc().watch(fireImmediately: true);
  }

  /// Searches budgets by title or description.
  Future<List<BudgetModel>> search(String query, String? ownerId) {
    var q = _isar.budgetModels.filter()
        .isDeletedEqualTo(false)
        .group((q) => q.titleContains(query, caseSensitive: false)
        .or().descriptionContains(query, caseSensitive: false));
    
    if (ownerId != null) q = q.ownerIdEqualTo(ownerId);
    return q.sortByStartDateDesc().findAll();
  }

  /// Finds budgets by status.
  Future<List<BudgetModel>> getBudgetsByStatus(String ownerId, String status) {
    return _isar.budgetModels.filter()
        .ownerIdEqualTo(ownerId)
        .statusEqualTo(status)
        .isDeletedEqualTo(false)
        .sortByStartDateDesc()
        .findAll();
  }

  /// Finds category-specific budgets.
  Future<List<BudgetModel>> getCategoryBudgets(String ownerId) {
    return _isar.budgetModels.filter()
        .ownerIdEqualTo(ownerId)
        .budgetTypeEqualTo('category')
        .isDeletedEqualTo(false)
        .sortByStartDateDesc()
        .findAll();
  }

  /// Supported Pagination method.
  Future<List<BudgetModel>> getBudgetsPaginated({
    required String? ownerId,
    required int limit,
    required int offset,
    String? status,
    String? budgetType,
  }) async {
    var query = _isar.budgetModels.filter().isDeletedEqualTo(false);
    
    if (ownerId != null && ownerId.isNotEmpty) {
      query = query.ownerIdEqualTo(ownerId);
    } else {
      query = query.ownerIdEqualTo('');
    }

    if (status != null) {
      query = query.statusEqualTo(status);
    }

    if (budgetType != null) {
      query = query.budgetTypeEqualTo(budgetType);
    }

    return query.sortByStartDateDesc().offset(offset).limit(limit).findAll();
  }
}
