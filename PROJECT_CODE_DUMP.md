# FinTrack Project Code Dump & Context

This document provides a comprehensive overview of the FinTrack project, its architecture, tech stack, and the source code of its core components.

---

## 1. Project Overview & Current Position

**Project Name:** FinTrack
**Target:** Enterprise-grade, offline-first personal finance application.
**Current Status:** The application launches and initializes, but has critical functional issues:
1.  **Account Creation Fails:** Users see a generic "Unable to save account" message. Real errors are likely suppressed or occurring in the Isar/Sync layers.
2.  **Google Sign-In Issues:** Authentication does not complete successfully.
3.  **UI Specification Mismatch:** Implementation needs refinement to match approved Material 3 designs.

---

## 2. Technology Stack

- **Framework:** Flutter (Stable)
- **UI:** Material 3, Dynamic Color
- **State Management:** Riverpod 2.x (StateNotifier, Providers)
- **Routing:** GoRouter
- **Local Database:** Isar (NoSQL, Offline-first)
- **Cloud/Backend:** Supabase (PostgreSQL, Auth, Sync)
- **Architecture:** MVC + Repository Pattern

---

## 3. Core Architecture Flow

**Execution Flow (e.g., Account Creation):**
`Presentation (Screen)` -> `Controller` -> `Repository` -> `Local Datasource (Isar)` -> `Sync Service (Queue)` -> `Remote Sync (Supabase)`

---

## 4. File Structure (Major Paths)

```
lib/
├── core/
│   ├── config/ (Env, Supabase config)
│   ├── constants/ (Routes, Colors, Icons)
│   ├── database/ (Isar init)
│   ├── network/ (Connectivity)
│   ├── services/ (App init, Auth, Sync, Session)
│   ├── theme/ (M3 Light/Dark)
│   └── utils/ (Formatters)
├── features/
│   ├── accounts/ (CRUD, Repository, Isar Model)
│   ├── analytics/ (Charts, Reports)
│   ├── auth/ (Supabase/Google Auth)
│   ├── budget/ (Limits, Alerts)
│   ├── goals/ (Targets, Contributions)
│   ├── home/ (Dashboard, Shell)
│   ├── splash/ (Startup logic)
│   ├── sync/ (Realtime status)
│   └── transactions/ (History, Logic)
└── main.dart
```

---

## 5. Source Code

### pubspec.yaml
```yaml
dependencies:
  flutter: { sdk: flutter }
  flutter_riverpod: ^2.6.1
  supabase_flutter: ^2.15.0
  dynamic_color: ^1.7.0
  isar: ^3.1.0+1
  go_router: ^16.0.0
  google_sign_in: ^7.2.0
  # ... other dependencies
```

### lib/main.dart
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FinTrackApp()));
}

class FinTrackApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initAsync = ref.watch(appInitializationProvider);
    return initAsync.when(
      data: (prefs) {
        final router = ref.watch(routerProvider);
        final themeMode = ref.watch(themeModeProvider);
        final settingsAsync = ref.watch(settingsProvider);
        return settingsAsync.when(
          data: (settings) => MaterialApp.router(
            routerConfig: router,
            theme: ThemeService.getTheme(settings, lightColorScheme),
            // ... config
          ),
          loading: () => LoadingWidget(),
          error: (err, _) => ErrorWidget(err),
        );
      },
      loading: () => LoadingWidget(),
      error: (err, _) => ErrorRetryWidget(err),
    );
  }
}
```

### lib/core/services/app_initializer.dart
```dart
class AppInitializer {
  Future<SharedPreferences> initialize() async {
    await dotenv.load(fileName: ".env");
    final prefs = await SharedPreferences.getInstance();
    await _supabaseService.initialize();
    await _isarService.initialize();
    return prefs;
  }
}
```

### lib/core/database/isar_initialization_service.dart
```dart
class IsarInitializationService {
  Future<void> initialize() async {
    _isar = await Isar.open([
      AccountModelSchema, TransactionModelSchema, BudgetModelSchema, // ...
    ], directory: path);
  }
}
```

### lib/features/accounts/data/repositories/account_repository_impl.dart
```dart
class AccountRepositoryImpl implements AccountRepository {
  @override
  Future<void> saveAccount(AccountModel account) async {
    final isNew = account.uuid.isEmpty;
    if (isNew) account.uuid = const Uuid().v4();
    account.updatedAt = DateTime.now();
    account.userId = _supabase.auth.currentUser?.id;

    await _localDatasource.putAccount(account);

    _syncService.queueSync(
      entityType: 'account',
      entityUuid: account.uuid,
      action: isNew ? 'create' : 'update',
      payload: account.toJson(),
    );
  }
}
```

### lib/core/services/sync_service.dart
```dart
class SyncService {
  Future<void> queueSync({required String entityType, ...}) async {
    final item = SyncQueueItem()..payload = jsonEncode(payload)..syncStatus = 'pending';
    await _isar.writeTxn(() => _isar.syncQueueItems.put(item));
    triggerSync();
  }

  Future<void> triggerSync() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return; // Guest mode
    await _processSyncQueue(userId);
    await _pullFromCloud(userId);
  }
}
```

### lib/features/auth/providers/auth_provider.dart
```dart
class AuthNotifier extends StateNotifier<AuthState> {
  Future<void> _init() async {
    await _sessionService.refreshSessionIfNeeded();
    final user = _repository.currentUser;
    if (user != null) state = AuthState.authenticated(user);
    else if (_sessionService.isGuestModeEnabled()) state = AuthState.guest();
    else state = AuthState.unauthenticated();
  }
}
```

### lib/core/services/auth_service.dart
```dart
class AuthService {
  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
  }
}
```

---

## 6. Known Issues Log for AI Assistant

- **Root Cause (Account Creation):** High probability of `userId` requirement in `AccountModel` violating guest mode, or `Isar.writeTxn` failing without proper error propagation.
- **Root Cause (Google Auth):** Potentially missing `google-services.json` or incorrect SHA-1/SHA-256 fingerprinting in the Supabase dashboard.
- **Root Cause (Blank Screen):** Splash screen potentially stuck in an infinite `while` loop waiting for `AuthStatus` to change from `loading`.

---

**Use this context to resolve the issues while strictly following the MVC + Repository Pattern.**
