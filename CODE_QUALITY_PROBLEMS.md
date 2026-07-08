# FinTrack Code Quality Problems Report

This report contains all **688 issues** identified by `flutter analyze` on July 4, 2026.

## Summary
- **Errors**: ~200
- **Warnings**: ~400
- **Info**: ~88

---

## Critical Infrastructure Issues (Isar Generation)
The following issues are due to missing generated files. Run `flutter pub run build_runner build` to resolve these.

- `lib/core/database/isar/collections/backup_history_model.dart`: uri_has_not_been_generated
- `lib/core/database/isar/collections/budget_model.dart`: uri_has_not_been_generated
- `lib/core/database/isar/collections/budget_recommendation_model.dart`: uri_has_not_been_generated
- `lib/core/database/isar/collections/goal_model.dart`: uri_has_not_been_generated
- `lib/core/database/isar/collections/settings_model.dart`: uri_has_not_been_generated
- `lib/core/database/isar/isar_database.dart`: undefined_identifier (BudgetModelSchema, etc.)

---

## Feature-Specific Problems

### 1. Goals Module (`lib/features/goals/`)
- **DataSources**: Undefined getters for `goalModels`, `milestoneModels`, `contributionModels` (Isar schemas).
- **Controllers**: `saveGoal` and `synchronize` not defined in `GoalRepository`.
- **Logic**: Unused field `_supabase`, unused local variable `now`.

### 2. Settings Module (`lib/features/settings/`)
- **UI Architecture**: Target of URI doesn't exist for providers and entities in multiple screens.
- **Controllers**: Multiple methods undefined in `SettingsController` (e.g., `toggleHapticFeedback`, `toggleScreenReaderHints`).
- **Entities**: Missing identifiers and invalid constant values in `currency_entity.dart`.

### 3. Analytics Module (`lib/features/analytics/`)
- **UI Elements**: Deprecated `background`, `withOpacity`, and `surfaceVariant` usage.
- **Controllers**: Undefined classes `CustomReportController`, `MonthlyReportController`, `YearlyReportController`.
- **Widgets**: `emerald` and `rose` colors not defined for `Colors` type.

### 4. Transactions Module (`lib/features/transactions/`)
- **Sync Architecture**: `TransactionEntity` undefined in `transaction_sync_adapter.dart`.
- **UI**: Deprecated `Share` class and `withOpacity` usage.
- **Logic**: Unused elements like `_pickImage`, `categoriesList`, and various local variables in repository implementations.

---

## Technical Debt & Deprecations
- **Supabase**: `anonKey` is deprecated; use `publishableKey`.
- **Material 3**: Multiple `withOpacity` calls should migrate to `withValues()`.
- **Riverpod**: `.stream` property on providers is deprecated.
- **Icons**: `shopping_bag_outline` and `medical_services_outline` are undefined.

---

## Full List of Issues (Truncated)
*Note: Due to the volume of issues (688), only a selection of unique patterns are shown below. See `analysis_output.txt` for the raw list.*

| File | Line | Severity | Problem | Code |
|------|------|----------|---------|------|
| `lib\core\config\supabase_config_service.dart` | 14 | info | 'anonKey' is deprecated | deprecated_member_use |
| `lib\core\constants\icons.dart` | 19 | error | 'shopping_bag_outline' isn't defined | undefined_getter |
| `lib\core\database\isar\isar_database.dart` | 18 | error | Undefined name 'BudgetModelSchema' | undefined_identifier |
| `lib\features\analytics\domain\utils\category_spending_service.dart` | 124 | error | Argument type mismatch in records | argument_type_not_assignable |
| `lib\features\analytics\presentation\screens\report_preview_screen.dart` | 137 | error | 'emerald' isn't defined for type 'Colors' | undefined_getter |
| `lib\features\settings\domain\entities\currency_entity.dart` | 18 | error | Expected an identifier | missing_identifier |
| `test\running_income_service_test.dart` | 8 | error | Not a const constructor | const_with_non_const |

---

## Action Plan
1. **Regenerate Code**: Run `flutter pub run build_runner build --delete-conflicting-outputs`.
2. **Update Theme Tokens**: Replace all `withOpacity` with `withValues`.
3. **Fix Color Definitions**: Map `emerald` and `rose` to hex codes or standard palette.
4. **Synchronize Interfaces**: Ensure `SettingsController` and `GoalRepository` methods match their declarations.
5. **Clean Imports**: Remove unused imports flagged throughout the project.
