import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/services/session_service.dart';
import '../../splash/providers/initialization_provider.dart';
import '../../sync/providers/sync_provider.dart';

enum AuthStatus { unknown, loading, guest, authenticated, unauthenticated, error }

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
      : status = AuthStatus.unknown,
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
      : status = AuthStatus.unauthenticated,
        user = null;

  const AuthState.error(this.errorMessage)
      : status = AuthStatus.error,
        user = null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SyncService _syncService;
  final SessionService _sessionService;

  AuthNotifier({
    required AuthRepository repository,
    required SyncService syncService,
    required SessionService sessionService,
  })  : _repository = repository,
        _syncService = syncService,
        _sessionService = sessionService,
        super(const AuthState.unknown()) {
    _init();
  }

  AuthNotifier.loading()
      : _repository = null as dynamic,
        _syncService = null as dynamic,
        _sessionService = null as dynamic,
        super(const AuthState.loading());

  Future<void> _init() async {
    state = const AuthState.loading();
    try {
      // 1. Restoring session
      await _sessionService.refreshSessionIfNeeded();

      final user = _repository.currentUser;
      final isGuest = _sessionService.isGuestModeEnabled();

      if (user != null) {
        state = AuthState.authenticated(user);
        await _sessionService.setLastLoginNow();
        _syncService.triggerSync();
      } else if (isGuest) {
        state = const AuthState.guest();
      } else {
        state = const AuthState.unauthenticated();
      }

      // 2. Listen to authentication state changes
      _repository.authStateChanges.listen((data) async {
        final session = data.session;
        if (session != null) {
          state = AuthState.authenticated(session.user);
          await _sessionService.setLastLoginNow();
          await _sessionService.setGuestMode(false);
          await _syncService.migrateGuestData();
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
    } catch (e) {
      state = AuthState.error(e.toString());
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
      await _sessionService.clearSession();
      await _repository.signOut();
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
  final init = ref.watch(appInitializationProvider);
  if (init.value == null) {
    return AuthNotifier.loading();
  }

  final repository = ref.watch(authRepositoryProvider);
  final syncService = ref.watch(syncServiceProvider);
  final sessionService = ref.watch(sessionServiceProvider);
  return AuthNotifier(
    repository: repository,
    syncService: syncService,
    sessionService: sessionService,
  );
});
