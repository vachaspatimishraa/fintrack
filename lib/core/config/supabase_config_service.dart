import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseConfigService {
  static bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      debugPrint("[SUPABASE] Already initialized.");
      return;
    }

    debugPrint("[SUPABASE] Initializing...");

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );

    _initialized = true;

    debugPrint("[SUPABASE] Initialization completed.");

    debugPrint("[SUPABASE] Verifying client...");
    final client = Supabase.instance.client;
    debugPrint(
      "[SUPABASE] Client verified. URL: ${SupabaseConfig.url}",
    );
  }
}
