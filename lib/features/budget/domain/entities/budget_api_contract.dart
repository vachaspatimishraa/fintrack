/// Formal definition of the Budget Module API and data exchange formats.
/// 
/// This class serves as a reference for integration between the frontend,
/// local database (Isar), and remote backend (Supabase).
class BudgetApiContract {
  /// Supabase Table Names
  static const String tableBudgets = 'budgets';
  static const String tableHistory = 'budget_history';
  static const String tableAlerts = 'budget_alerts';
  static const String tableCategories = 'budget_categories';

  /// Sync Operations
  static const String opCreate = 'create';
  static const String opUpdate = 'update';
  static const String opDelete = 'delete';
  static const String opRestore = 'restore';
  static const String opArchive = 'archive';

  /// Status Constants
  static const String statusActive = 'active';
  static const String statusWarning = 'warning';
  static const String statusExceeded = 'exceeded';
  static const String statusCompleted = 'completed';
  static const String statusArchived = 'archived';

  /// Field Mappings (JSON keys)
  static const String fId = 'id';
  static const String fOwnerId = 'owner_id';
  static const String fTitle = 'title';
  static const String fAmount = 'amount';
  static const String fSpentAmount = 'spent_amount';
  static const String fRemainingAmount = 'remaining_amount';
  static const String fProgress = 'progress';
  static const String fStatus = 'status';
  static const String fVersion = 'version';
  static const String fUpdatedAt = 'updated_at';
}
