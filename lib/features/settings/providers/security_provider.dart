import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/session_manager.dart';
import '../domain/services/biometric_service.dart';
import '../domain/services/secure_storage_service.dart';
import '../../auth/providers/auth_provider.dart';

final sessionManagerProvider = Provider<SessionManager>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return SessionManager(storage);
});

final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

class LockState {
  final bool isLocked;
  final bool isAuthenticating;
  final String? error;

  LockState({this.isLocked = false, this.isAuthenticating = false, this.error});

  LockState copyWith({bool? isLocked, bool? isAuthenticating, String? error}) {
    return LockState(
      isLocked: isLocked ?? this.isLocked,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      error: error ?? this.error,
    );
  }
}

class LockNotifier extends StateNotifier<LockState> {
  final Ref _ref;

  LockNotifier(this._ref) : super(LockState());

  void lock() {
    state = state.copyWith(isLocked: true);
  }

  Future<void> unlock() async {
    state = state.copyWith(isLocked: false, error: null);
    await _ref.read(sessionManagerProvider).unlock();
  }

  Future<bool> authenticate(String reason) async {
    state = state.copyWith(isAuthenticating: true, error: null);
    final service = _ref.read(biometricServiceProvider);
    
    final success = await service.authenticate(
      reason: reason,
    );
    
    if (success) {
      await unlock();
    } else {
      state = state.copyWith(isAuthenticating: false, error: 'auth_fail');
    }
    return success;
  }
}

final lockProvider = StateNotifierProvider<LockNotifier, LockState>((ref) {
  final notifier = LockNotifier(ref);
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (next.status == AuthStatus.unauthenticated) {
      notifier.unlock();
    }
  });
  return notifier;
});
