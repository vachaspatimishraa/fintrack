import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionService {
  final SharedPreferences _prefs;
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _keyLastLogin = 'auth_last_login_time';
  static const String _keyGuestMode = 'auth_guest_mode_enabled';

  SessionService(this._prefs);

  Future<void> setLastLoginNow() async {
    await _prefs.setString(_keyLastLogin, DateTime.now().toIso8601String());
  }

  DateTime? getLastLoginTime() {
    final raw = _prefs.getString(_keyLastLogin);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setGuestMode(bool enabled) async {
    await _prefs.setBool(_keyGuestMode, enabled);
  }

  bool isGuestModeEnabled() {
    return _prefs.getBool(_keyGuestMode) ?? false;
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyLastLogin);
    await _prefs.remove(_keyGuestMode);
  }

  bool isSessionValid() {
    final session = _supabase.auth.currentSession;
    if (session == null) return false;
    
    // Check if access token is expired or expires very soon (e.g. less than 10 seconds remaining)
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return expiresAt > (now + 10);
  }

  Future<void> refreshSessionIfNeeded() async {
    if (_supabase.auth.currentSession != null && !isSessionValid()) {
      try {
        await _supabase.auth.refreshSession();
      } catch (_) {
        // Ignored or handled by auth provider state changes
      }
    }
  }
}
