import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({
    required AuthService authService,
  })  : _authService = authService;

  User? get currentUser => _authService.currentUser;
  Session? get currentSession => _authService.currentSession;
  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  Future<void> signInWithGoogle() => _authService.signInWithGoogle();
  Future<void> signOut() => _authService.signOut();
}
