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
      debugPrint("[INIT WARNING] Failed to load .env file. Falling back to default settings: $e");
    }

    // 2. Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    debugPrint("[INIT] SharedPreferences initialized.");

    // 3. Initialize Supabase safely (with offline recovery fallback)
    try {
      debugPrint("[INIT] Initializing Supabase...");
      await _supabaseService.initialize().timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint("[INIT TIMEOUT] Supabase initialization timed out after 10s.");
        throw TimeoutException("Supabase initialization timed out.");
      });
      debugPrint("[INIT] Supabase initialized successfully.");
    } catch (e) {
      debugPrint("[INIT WARNING] Supabase initialization failed. Continuing in offline-first mode: $e");
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
