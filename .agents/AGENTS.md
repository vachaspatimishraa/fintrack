# FinTrack Analytics Coding Standards & AI Development Contract

Every AI assistant contributing to the FinTrack codebase, and specifically the Analytics Module, must adhere strictly to these engineering contracts.

## 1. Architectural Integrity (Clean Architecture + MVC)
- **Separation of Layers**: Features must be partitioned into:
  - `domain/`: Entities and Repository interfaces. MUST be pure Dart (no `flutter/material.dart` imports).
  - `data/`: Repositories implementations and local/remote data sources.
  - `presentation/`: Controllers, screens, widgets, and bottom sheets.
- **Single Source of Truth**: UI components must never access databases (Isar) or network clients (Supabase) directly. Access must go through the repository layer.
- **State Management**: Use Riverpod providers (`FutureProvider`, `StreamProvider`, `StateNotifierProvider`). Avoid mutable global state.

## 2. Coding Practices & Conventions
- **Language**: Use Dart 3.x features (patterns, records, destructuring) and strict type safety.
- **Immutability**: All model and entity classes must be immutable (using `final` fields, `const` constructors, `copyWith()`, and overriding `operator ==`).
- **Naming Conventions**:
  - Classes and Enums: `PascalCase`
  - Variables and Constants: `camelCase`
  - Filenames: `snake_case.dart`

## 3. Offline-First Policy
- **Local Priority**: All write operations must complete locally in Isar first.
- **Calculations isolation**: Analytics, health scores, and rule engines must execute purely on local database states, functioning without active internet connection.

## 4. Security & Privacy Controls
- **Secrets Management**: Never hardcode API keys, credentials, or tokens.
- **Data Minimization in Logging**: Logs must never include transactional details (descriptions, notes) or raw financial figures (dollar/rupee amounts).

## 5. Performance Thresholds
- **Dashboard Load**: `< 150ms`
- **KPI Generation**: `< 40ms`
- **Financial Health Calculation**: `< 60ms`
- **AI Insights Rule Generation**: `< 120ms`
- **Chart Rendering**: `< 100ms` at stable 60 FPS.
- **Heavy aggregation**: Background calculations with large datasets should delegate CPU tasks to Dart isolates (via `compute`).

## 6. Accessibility (a11y)
- **Minimum Touch Target**: Interactive components must have at least `48dp` touch targets.
- **Semantic Labels**: Custom painters (like charts) must be wrapped inside `Semantics` widgets to support screen readers.
- **Responsive Layouts**: Handle phone (single column), tablet (dual-pane), and foldables (adaptive panels).

## 7. Testing Requirements
- **Coverage**:
  - Repositories: `95%`
  - Controllers: `90%`
  - Engines & Calculators: `95%`
  - UI Widgets: `80%`
- **Quality Checklist**: All code must compile cleanly, pass `flutter analyze`, and pass the test suite before approval.

## 8. Reports & Export Module Contract
- **Modular Exporters**: PDF, Excel, and CSV generation must be delegated to separate engines (`PDFExportService`, `ExcelExportService`, `CsvExportService`) rather than repository files.
- **Isolate Offloading**: Calculations and report writing operations must execute in background thread isolates via `ExportOptimizer.runInBackground` to prevent UI thread blocks.
- **History Metadata Isolation**: Only metadata references (name, size, paths) should be persisted in Isar and synced. Raw files remain local and offline.
- **Validation**: Enforce size boundaries (max 50 MB) and extension checks prior to export completion.

## 9. Goals Module Contract
- **Calculation Isolation**: Goal progress rates, milestones status, and projected completions must be computed by a deterministic engine (`GoalEngine`) decoupled from UI views.
- **Contribution History**: Goal contributions must be recorded as separate log entries, allowing step-by-step progress tracking and repeatability.
- **Notification Scheduling**: Reminders and milestones alerts must communicate via `GoalNotificationService` abstractions without referencing platform APIs or widgets directly.
- **Offline Integrity**: Goal creation, milestone evaluation, and contributions tracking must run completely locally, syncing metadata asynchronously.


