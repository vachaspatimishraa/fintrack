import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config_service.dart';
import '../database/isar_initialization_service.dart';

class AppInitializer {
  final IsarInitializationService _isarService;
  final SupabaseConfigService _supabaseService;

  AppInitializer(this._isarService, this._supabaseService);

  Future<SharedPreferences> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      throw Exception("Failed to load .env file: $e");
    }

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw Exception("Required environment variables (SUPABASE_URL, SUPABASE_ANON_KEY) are missing or empty.");
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
