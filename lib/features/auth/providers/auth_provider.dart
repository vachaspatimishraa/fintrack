import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/services/session_service.dart';
import '../../splash/providers/initialization_provider.dart';
import '../../sync/providers/sync_provider.dart';
import '../../settings/providers/settings_provider.dart';

enum AuthStatus { guest, authenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.unknown()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null;

  const AuthState.authenticated(this.user)
      : status = AuthStatus.authenticated,
        errorMessage = null;

  const AuthState.guest()
      : status = AuthStatus.guest,
        user = null,
        errorMessage = null;

  const AuthState.unauthenticated({this.errorMessage})
      : status = AuthStatus.error,
        user = null;

  const AuthState.error(this.errorMessage)
      : status = AuthStatus.error,
        user = null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SyncService _syncService;
  final SessionService _sessionService;
  final Ref _ref;

  AuthNotifier({
    required AuthRepository repository,
    required SyncService syncService,
    required SessionService sessionService,
    required Ref ref,
  })  : _repository = repository,
        _syncService = syncService,
        _sessionService = sessionService,
        _ref = ref,
        super(const AuthState.loading()) {
    _init();
  }

  AuthNotifier.loading()
      : _repository = null as dynamic,
        _syncService = null as dynamic,
        _sessionService = null as dynamic,
        _ref = null as dynamic,
        super(const AuthState.loading());

  Future<void> _init() async {
    debugPrint("[LOG] AuthNotifier._init START");
    state = const AuthState.loading();
    try {
      // 1. Restoring session
      debugPrint("[LOG] Before sessionService.refreshSessionIfNeeded()");
      await _sessionService.refreshSessionIfNeeded();
      debugPrint("[LOG] After sessionService.refreshSessionIfNeeded()");

      final user = _repository.currentUser;
      final isGuest = _sessionService.isGuestModeEnabled();
      debugPrint("[LOG] AuthNotifier current user: ${user?.email}, isGuest: $isGuest");

      if (user != null && Supabase.instance.client.auth.currentUser != null) {
        debugPrint("[LOG] User authenticated");
        state = AuthState.authenticated(user);
        debugPrint("[LOG] Before sessionService.setLastLoginNow()");
        await _sessionService.setLastLoginNow();
        debugPrint("[LOG] After sessionService.setLastLoginNow()");
        _syncService.triggerSync();
      } else if (isGuest) {
        debugPrint("[LOG] Guest mode enabled");
        state = const AuthState.guest();
      } else {
        debugPrint("[LOG] NOT authenticated and NOT guest");
        state = const AuthState.unauthenticated();
      }

      // 2. Listen to authentication state changes
      debugPrint("[LOG] Setting up authStateChanges listener");
      _repository.authStateChanges.listen((data) async {
        debugPrint("[LOG] AuthState changed: ${data.event}");
        final session = data.session;
        if (session != null && Supabase.instance.client.auth.currentUser != null) {
          state = AuthState.authenticated(session.user);
          await _sessionService.setLastLoginNow();
          await _sessionService.setGuestMode(false);
          _syncService.triggerSync();
        } else {
          final currentGuest = _sessionService.isGuestModeEnabled();
          if (currentGuest) {
            state = const AuthState.guest();
          } else {
            state = const AuthState.unauthenticated();
          }
        }
      });
      debugPrint("[LOG] AuthNotifier._init DONE");
    } catch (e) {
      debugPrint("[LOG] AuthNotifier._init ERROR: $e");
      state = AuthState.error(e.toString());
    }
  }

  Future<bool> hasGuestData() => _syncService.hasGuestData();

  Future<void> migrateGuestData() async {
    try {
      await _syncService.migrateGuestData();
    } catch (e) {
      debugPrint('Guest data migration error: $e');
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AuthState.loading();
    try {
      await _repository.signInWithGoogle();
    } catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.toString());
    }
  }

  Future<void> enableGuestMode() async {
    state = const AuthState.loading();
    try {
      await _sessionService.setGuestMode(true);
      state = const AuthState.guest();
    } catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      await _repository.signOut();
      await _sessionService.clearSession();
      
      //Disable Guest Mode on signOut
      await _sessionService.setGuestMode(false);
      
      //Disable cloud sync
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      final currentSettings = await settingsRepo.loadSettings();
      await settingsRepo.updateSettings(currentSettings.copyWith(syncEnabled: false));
      
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

// Global service and repository providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(supabase: Supabase.instance.client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepository(authService: authService);
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  // SharedPreferences is available after startup initialization
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionService(prefs);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final syncService = ref.watch(syncServiceProvider);
  final sessionService = ref.watch(sessionServiceProvider);
  return AuthNotifier(
    repository: repository,
    syncService: syncService,
    sessionService: sessionService,
    ref: ref,
  );
});

final migrationPromptShownProvider = StateProvider<bool>((ref) => false);
