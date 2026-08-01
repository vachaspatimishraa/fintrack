import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';
import '../config/supabase_config_service.dart';
import '../database/isar_initialization_service.dart';

class AppInitializer {
  final IsarInitializationService _isarService;
  final SupabaseConfigService _supabaseService;

  AppInitializer(this._isarService, this._supabaseService);

  Future<SharedPreferences> initialize() async {
    final url = Environment.supabaseUrl;
    final anonKey = Environment.supabaseAnonKey;
    if (url.isEmpty || anonKey.isEmpty) {
      // In development or when dart-define is omitted, warn or proceed
      // debugPrint("SUPABASE_URL or SUPABASE_ANON_KEY empty via Environment");
    }

    final prefs = await SharedPreferences.getInstance();

    try {
      await _supabaseService.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException("Supabase initialization timed out.");
        },
      );
    } catch (e) {
      throw Exception("Supabase initialization failed: $e");
    }

    await _isarService.initialize();

    return prefs;
  }
}
