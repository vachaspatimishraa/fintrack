import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/env.dart';

class AuthService {
  final SupabaseClient _supabase;
  bool _googleSignInInitialized = false;

  AuthService({required SupabaseClient supabase}) : _supabase = supabase;

  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      try {
        await GoogleSignIn.instance.initialize(
          clientId: Env.googleIosClientId.isEmpty ? null : Env.googleIosClientId,
          serverClientId: Env.googleWebClientId.isEmpty ? null : Env.googleWebClientId,
        );
        _googleSignInInitialized = true;
      } catch (e) {
        // Already initialized or platform error
        _googleSignInInitialized = true; 
      }
    }
  }

  Future<void> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    
    final googleUser = await GoogleSignIn.instance.authenticate();
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled.');
    }
    
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('No ID Token found.');
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    try {
      await _ensureGoogleSignInInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}
