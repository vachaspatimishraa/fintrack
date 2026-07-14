import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/session_manager.dart';
import '../domain/services/biometric_service.dart';
import '../domain/services/secure_storage_service.dart';
import '../providers/settings_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/domain/entities/settings_entity.dart';

final sessionManagerProvider = Provider<SessionManager>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return SessionManager(storage);
});

final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

class AppLockState {
  final bool appLockEnabled;
  final bool isUnlocked;
  final DateTime? lastAuthenticatedAt;
  final String sessionTimeout;
  final bool authenticationInProgress;
  final DateTime? suspendedAt;
  final String? error;

  AppLockState({
    required this.appLockEnabled,
    required this.isUnlocked,
    this.lastAuthenticatedAt,
    required this.sessionTimeout,
    required this.authenticationInProgress,
    this.suspendedAt,
    this.error,
  });

  AppLockState copyWith({
    bool? appLockEnabled,
    bool? isUnlocked,
    DateTime? lastAuthenticatedAt,
    String? sessionTimeout,
    bool? authenticationInProgress,
    DateTime? suspendedAt,
    bool clearSuspendedAt = false,
    String? error,
    bool clearError = false,
  }) {
    return AppLockState(
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      lastAuthenticatedAt: lastAuthenticatedAt ?? this.lastAuthenticatedAt,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      authenticationInProgress: authenticationInProgress ?? this.authenticationInProgress,
      suspendedAt: clearSuspendedAt ? null : (suspendedAt ?? this.suspendedAt),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LockNotifier extends StateNotifier<AppLockState> {
  final Ref _ref;

  LockNotifier(this._ref)
      : super(AppLockState(
          appLockEnabled: false,
          isUnlocked: false,
          sessionTimeout: 'never',
          authenticationInProgress: false,
        )) {
    _init();
  }

  void _init() {
    _ref.listen<AsyncValue<SettingsEntity>>(settingsProvider, (prev, next) {
      next.whenData((settings) {
        state = state.copyWith(
          appLockEnabled: settings.appLockEnabled,
          sessionTimeout: settings.sessionTimeout,
        );
      });
    }, fireImmediately: true);
  }

  void lock() {
    if (!state.isUnlocked) return;
    print('APP LOCK: Locking application');
    state = state.copyWith(isUnlocked: false, clearError: true);
  }

  Future<void> unlock() async {
    print('APP LOCK: Unlocking application. isUnlocked = true');
    state = state.copyWith(
      isUnlocked: true,
      authenticationInProgress: false,
      clearError: true,
      lastAuthenticatedAt: DateTime.now(),
      clearSuspendedAt: true,
    );
    await _ref.read(sessionManagerProvider).unlock();
  }

  void handleAppPaused() {
    print('APP LOCK: App Resumed/Paused check: App Paused');
    if (state.appLockEnabled && state.isUnlocked) {
      print('APP LOCK: App was unlocked, saving suspendedAt');
      state = state.copyWith(suspendedAt: DateTime.now());
    }
  }

  void handleAppResumed() {
    print('APP LOCK: App Resumed/Paused check: App Resumed');
    if (state.appLockEnabled && state.suspendedAt != null) {
      final suspendedAt = state.suspendedAt!;
      final duration = DateTime.now().difference(suspendedAt);
      final timeout = _getDurationFromPreference(state.sessionTimeout);

      print('APP LOCK: Suspended duration: ${duration.inSeconds}s, Timeout: $timeout');

      if (timeout != null && duration >= timeout) {
        print('APP LOCK: Session Timeout Expired, locking app');
        state = state.copyWith(isUnlocked: false, clearSuspendedAt: true);
      } else {
        print('APP LOCK: Session Timeout NOT Expired or Never, keeping unlocked');
        state = state.copyWith(clearSuspendedAt: true);
      }
    } else {
      print('APP LOCK: Authentication Skipped (not enabled or suspendedAt is null)');
    }
  }

  Duration? _getDurationFromPreference(String preference) {
    switch (preference) {
      case 'immediately':
        return Duration.zero;
      case '1_min':
        return const Duration(minutes: 1);
      case '5_min':
        return const Duration(minutes: 5);
      case '15_min':
        return const Duration(minutes: 15);
      case '30_min':
        return const Duration(minutes: 30);
      case '1_hour':
        return const Duration(hours: 1);
      case 'never':
      default:
        return null;
    }
  }

  Future<bool> authenticate(String reason) async {
    if (state.authenticationInProgress || state.isUnlocked) {
      print('APP LOCK: Authentication Already Running or Unlocked, skipping request');
      return false;
    }

    print('APP LOCK: Authentication Started');
    state = state.copyWith(authenticationInProgress: true, clearError: true);

    try {
      final service = _ref.read(biometricServiceProvider);
      
      // Read saved biometricEnabled setting
      final settings = _ref.read(settingsProvider).value;
      final biometricEnabled = settings?.biometricEnabled ?? true;
      
      final success = await service.authenticate(
        reason: reason,
        biometricEnabled: biometricEnabled,
      );

      if (success) {
        print('APP LOCK: Authentication Success');
        await unlock();
        return true;
      } else {
        print('APP LOCK: Authentication Failed');
        state = state.copyWith(authenticationInProgress: false, error: 'auth_fail');
        return false;
      }
    } catch (e) {
      print('APP LOCK: Authentication ERROR: $e');
      state = state.copyWith(authenticationInProgress: false, error: e.toString());
      return false;
    }
  }
}

final lockProvider = StateNotifierProvider<LockNotifier, AppLockState>((ref) {
  final notifier = LockNotifier(ref);
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (next.status == AuthStatus.guest && previous?.status == AuthStatus.authenticated) {
      notifier.unlock();
    }
  });
  return notifier;
});
