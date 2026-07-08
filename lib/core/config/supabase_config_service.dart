import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseConfigService {
  Future<void> initialize() async {
    // If Supabase is already initialized, calling initialize again can cause issues,
    // but supabase_flutter does not expose a clean "isInitialized" boolean directly.
    // However, we can catch the exception if it is already initialized, or check instance.
    try {
      Supabase.instance;
    } catch (_) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
      );
    }
  }
}
