import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
export '../../providers/auth_provider.dart' show AuthStatus, AuthState, authProvider;

class AuthController {
  final Ref _ref;

  AuthController(this._ref);

  Future<void> loginWithGoogle() => _ref.read(authProvider.notifier).loginWithGoogle();
  Future<void> continueAsGuest() => _ref.read(authProvider.notifier).enableGuestMode();
  Future<void> logout() => _ref.read(authProvider.notifier).signOut();
}

final authControllerProvider = Provider<AuthController>((ref) => AuthController(ref));
