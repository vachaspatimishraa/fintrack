import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/supabase_config_service.dart';
import '../../../../core/database/isar_initialization_service.dart';
import '../../../../core/services/app_initializer.dart';

final isarInitializationServiceProvider = Provider<IsarInitializationService>((ref) {
  return IsarInitializationService();
});

final supabaseConfigServiceProvider = Provider<SupabaseConfigService>((ref) {
  return SupabaseConfigService();
});

final appInitializerProvider = Provider<AppInitializer>((ref) {
  final isar = ref.watch(isarInitializationServiceProvider);
  final supabase = ref.watch(supabaseConfigServiceProvider);
  return AppInitializer(isar, supabase);
});

// Provider that holds the initialized SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  final init = ref.watch(appInitializationProvider);
  return init.requireValue;
});

// Asynchronous provider that drives the startup flow
final appInitializationProvider = FutureProvider<SharedPreferences>((ref) async {
  final initializer = ref.watch(appInitializerProvider);
  return await initializer.initialize();
});
