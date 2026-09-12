import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fintrack/core/config/supabase_config.dart';

class SupabaseConfigService {
  static bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );

    _initialized = true;
  }
}
