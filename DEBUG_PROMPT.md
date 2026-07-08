# FinTrack Project Overview & Debugging Mega-Prompt

Use this document to provide ChatGPT or any AI assistant with complete context about the FinTrack project to solve the current functional and UI issues.

---

## 1. Project Context & Architecture

**Project Name:** FinTrack
**Target:** Enterprise-grade financial tracking application.
**Tech Stack:**
- **Language:** Flutter (Dart)
- **UI:** Material 3, Dynamic Color
- **State Management:** Riverpod (StateNotifier, Provider, FutureProvider)
- **Routing:** GoRouter
- **Local Persistence:** Isar (NoSQL) with Offline-First strategy
- **Cloud Persistence:** Supabase (PostgreSQL, Auth, Realtime Sync)
- **Architecture:** MVC + Repository Pattern (Presentation -> Controller -> Repository -> Datasource)

---

## 2. Current Critical Issues

### Issue 1: Nothing showing on the screen (Blank Screen)
The app stays on a blank screen or a loader. This is likely related to the `appInitializationProvider` or `authProvider` not resolving, or a routing loop in `GoRouter`.

### Issue 2: Account creation fails
User receives "Unable to save account. Please try again." No detailed error is shown. 
**Likely cause:** Schema mismatch, missing `userId` in guest mode, or Isar transaction failure.

### Issue 3: Google Sign-In failure
Authentication never completes successfully. 
**Checkpoints:** Android SHA-1/SHA-256 in Supabase dashboard, `google-services.json`, Redirect URIs.

### Issue 4: UI Specification Mismatch
Several screens do not match the approved FinTrack design (Material 3 compliance, spacing, typography).

---

## 3. Core Coding Snippets

### lib/main.dart (Entry Point)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarService = IsarInitializationService();
  final supabaseService = SupabaseConfigService();
  final initializer = AppInitializer(isarService, supabaseService);
  final prefs = await initializer.initialize();

  runApp(
    ProviderScope(
      overrides: [
        isarInitializationServiceProvider.overrideWithValue(isarService),
        supabaseConfigServiceProvider.overrideWithValue(supabaseService),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const FinTrackApp(),
    ),
  );
}

class FinTrackApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) => MaterialApp.router(
        routerConfig: router,
        // ... theme and locale config
      ),
      loading: () => const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator()))),
      error: (err, _) => MaterialApp(home: Scaffold(body: Center(child: Text('Error: $err')))),
    );
  }
}
```

### lib/core/router/app_router.dart (Navigation Logic)
```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final status = authState.status;
      // ... redirect logic based on AuthStatus (unknown, loading, authenticated, guest, unauthenticated)
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
    ],
  );
});
```

### lib/features/auth/providers/auth_provider.dart (Auth State)
```dart
class AuthNotifier extends StateNotifier<AuthState> {
  // ... handles _init(), loginWithGoogle(), signOut()
  // Transitions between statuses: unknown -> loading -> authenticated/guest/unauthenticated
}
```

---

## 4. Debugging & Repair Instructions (Phase-by-Phase)

### Phase 1: Fix Account Creation
- Trace `AccountController.saveAccount()` through `AccountRepository` to `AccountLocalDatasource`.
- Verify `Isar.writeTxn()` completes.
- Ensure `SyncService.queueSync()` does not block local save if remote fails.
- Replace generic "Unable to save" snackbars with `debugPrint(e.toString())` and `debugPrintStack()`.

### Phase 2: Fix Google Sign-In
- Verify Supabase configuration.
- Check Redirect URIs in `SupabaseConfigService`.
- Inspect `google_sign_in` package implementation in `AuthRepository`.

### Phase 3: Repair Blank Screen
- Check if `SplashScreen` successfully calls `splashController.handleAppStartup()`.
- Inspect `handleAppStartup` for infinite `while` loops waiting for `AuthStatus.loading`.
- Verify `appInitializationProvider` completes.

### Phase 4: UI Refinement
- Update `HomeScreen` and children to strictly follow Material 3.
- Standardize spacing and typography using `Theme.of(context).textTheme`.

---

## 5. File Structure
```
lib/
├── core/ (router, database, config, shared services)
├── shared/ (common widgets, utils)
└── features/
    ├── auth/ (Supabase auth, Google Login)
    ├── splash/ (Initial loading, redirects)
    ├── home/ (Dashboard, BottomNav)
    ├── accounts/ (Account CRUD, Isar storage)
    ├── transactions/ (History, Sync Queue)
    ├── budget/ (Limits, Alerts)
    └── settings/ (Theme, Privacy, Biometrics)
```
