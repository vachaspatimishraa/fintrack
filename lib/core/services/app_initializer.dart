import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config_service.dart';
import '../database/isar_initialization_service.dart';

class AppInitializer {
  final IsarInitializationService _isarService;
  final SupabaseConfigService _supabaseService;

  AppInitializer(this._isarService, this._supabaseService);

  Future<SharedPreferences> initialize() async {
    // 1. Load environment variables safely
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("[INIT] Environment variables loaded successfully.");
    } catch (e) {
      debugPrint("[INIT ERROR] Failed to load .env file: $e");
      throw Exception("Failed to load .env file: $e");
    }

    // Verify env variables exist
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw Exception("Required environment variables (SUPABASE_URL, SUPABASE_ANON_KEY) are missing or empty.");
    }

    // 2. Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    debugPrint("[INIT] SharedPreferences initialized.");

    // 3. Initialize Supabase safely
    try {
      debugPrint("[INIT] Initializing Supabase...");
      await _supabaseService.initialize().timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint("[INIT TIMEOUT] Supabase initialization timed out after 10s.");
        throw TimeoutException("Supabase initialization timed out.");
      });
      debugPrint("[INIT] Supabase initialized successfully.");
    } catch (e) {
      debugPrint("[INIT ERROR] Supabase initialization failed: $e");
      throw Exception("Supabase initialization failed: $e");
    }

    // 4. Initialize Isar Database
    try {
      debugPrint("[INIT] Initializing Isar Database...");
      await _isarService.initialize();
      debugPrint("[INIT] Isar Database initialized.");
    } catch (e) {
      debugPrint("[INIT ERROR] Isar Database initialization failed: $e");
      rethrow;
    }

    return prefs;
  }
}
