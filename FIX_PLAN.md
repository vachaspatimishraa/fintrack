# FinTrack — Flutter Analyze Fix Plan

Paste this whole file as a prompt into your AI coding assistant (Claude Code, Cursor, etc.) inside Android Studio / your repo root. Work through it phase by phase — **don't let the assistant jump straight to "fix everything"**, since most of the 688 issues are downstream of Phase 1.

---

## Context for the assistant

This is a Flutter app called **FinTrack** using **Riverpod, Firebase, Isar (local DB), Supabase, Clean Architecture**. Running `flutter analyze` currently reports **688 issues** (~200 errors, ~400 warnings, ~88 info). Most errors cascade from missing Isar generated code — fix that first, then re-run analyze before touching anything else, because a large percentage of the remaining errors will disappear automatically.

---

## Phase 1 — Regenerate Isar code (fixes the majority of errors)

Root cause: `.g.dart` files for Isar collections were never generated or are stale.

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Affected collections to verify after generation:
- `lib/core/database/isar/collections/backup_history_model.dart`
- `lib/core/database/isar/collections/budget_model.dart`
- `lib/core/database/isar/collections/budget_recommendation_model.dart`
- `lib/core/database/isar/collections/goal_model.dart`
- `lib/core/database/isar/collections/settings_model.dart`

**Check that:**
1. Each collection class has `@collection` (or `@Collection()`) annotation.
2. `part 'xxx_model.g.dart';` is declared in each file.
3. `lib/core/database/isar/isar_database.dart` imports the generated schemas correctly (`BudgetModelSchema`, etc. should resolve after generation — do not manually stub these).

➡️ **After this step, run `flutter analyze` again and get a fresh count before proceeding.** Many "undefined getter/identifier" errors in Goals, Settings, and Analytics modules are caused by this alone.

---

## Phase 2 — Fix real structural/interface mismatches

These will NOT be fixed by codegen — they're genuine code bugs.

### Goals module (`lib/features/goals/`)
- Add missing methods `saveGoal` and `synchronize` to `GoalRepository` (interface + implementation), or remove calls to them if obsolete.
- Remove unused field `_supabase` and unused local variable `now` if truly unused, or wire them in if they were meant to be used.
- Confirm datasource getters (`goalModels`, `milestoneModels`, `contributionModels`) match the Isar collection names generated in Phase 1.

### Settings module (`lib/features/settings/`)
- Fix broken import paths ("Target of URI doesn't exist") for providers/entities — likely a folder was renamed/moved.
- Add missing methods to `SettingsController`: `toggleHapticFeedback`, `toggleScreenReaderHints`, and any others analyze flags.
- Fix `currency_entity.dart` — "Expected an identifier" and invalid constant values usually mean a typo, reserved keyword, or malformed enum/const declaration. Review that file directly.

### Analytics module (`lib/features/analytics/`)
- Define missing controllers: `CustomReportController`, `MonthlyReportController`, `YearlyReportController` (or fix their import paths if they exist elsewhere).
- Add `emerald` and `rose` as custom colors (e.g., extend a `AppColors` class) instead of trying to access them on `Colors` directly — `Colors.emerald` doesn't exist in Flutter's Material palette.
- Fix the argument type mismatch in `category_spending_service.dart:124` (records feature — check tuple/record type shape).

### Transactions module (`lib/features/transactions/`)
- Fix `TransactionEntity` undefined in `transaction_sync_adapter.dart` — check import path and confirm entity wasn't renamed/moved.
- Remove unused elements: `_pickImage`, `categoriesList`, and flagged local variables — or wire them up if incomplete features.

### Icons
- `shopping_bag_outline` and `medical_services_outline` are undefined — these don't exist in the icon set being used (likely `Icons` or a custom icon font). Replace with valid equivalents (e.g., `Icons.shopping_bag_outlined`, `Icons.medical_services_outlined`) or add them to the custom icon font if this is a custom `IconData` set.

### Tests
- `test/running_income_service_test.dart:8` — "Not a const constructor": remove the `const` keyword from that instantiation or make the constructor const if it should be immutable.

---

## Phase 3 — Deprecations / technical debt cleanup

Do this in a single dedicated pass with find-and-replace, module by module:

1. **Supabase**: replace `anonKey` with `publishableKey` in `supabase_config_service.dart` and anywhere else it's referenced.
2. **Material 3 color API**: replace all `.withOpacity(x)` calls with `.withValues(alpha: x)`.
3. **Material 3 surface tokens**: replace deprecated `background` / `surfaceVariant` usages with the current `surface` / `surfaceContainerHighest` equivalents from the current `ColorScheme`.
4. **Riverpod**: replace deprecated `.stream` usage on providers with the current recommended API (check provider type — likely `StreamProvider` should be watched directly rather than via `.stream`).
5. **Share package**: migrate from deprecated `Share` class to the current `SharePlus.instance.share(...)` API (or whatever the currently pinned `share_plus` version recommends — check `pubspec.yaml` version).

---

## Phase 4 — Lint cleanup (unused imports/variables)

Run:
```bash
dart fix --apply
```
This auto-fixes many simple lints (unused imports, prefer_const, etc.) safely. Then manually review remaining `unused_local_variable` / `unused_field` warnings — for each one, decide: delete it, or it's a sign of an incomplete feature that needs finishing.

---

## Suggested execution order for the assistant

1. Run Phase 1, regenerate code, re-run `flutter analyze`, report new issue count.
2. Fix Phase 2 module-by-module (Goals → Settings → Analytics → Transactions → Icons → Tests), re-running `flutter analyze` after each module.
3. Do Phase 3 as global find/replace passes.
4. Run `dart fix --apply`, then manually clean remaining lints in Phase 4.
5. Final `flutter analyze` — target: 0 errors, minimal warnings.

Report back after each phase with the new `flutter analyze` issue count so we can track progress instead of trying to fix all 688 at once.
