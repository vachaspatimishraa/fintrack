import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/settings/domain/services/theme_service.dart';
import 'features/settings/domain/services/dynamic_color_service.dart';
import 'features/settings/domain/services/localization_service.dart';
import 'core/database/isar_initialization_service.dart';
import 'core/config/supabase_config_service.dart';
import 'core/services/app_initializer.dart';

import 'features/settings/presentation/widgets/authentication_guard.dart';
import 'features/splash/providers/initialization_provider.dart';

void main() async {
  debugPrint("[LOG] STARTING MAIN...");
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("[LOG] WidgetsFlutterBinding.ensureInitialized() DONE");
  
  final isarService = IsarInitializationService();
  final supabaseService = SupabaseConfigService();
  final initializer = AppInitializer(isarService, supabaseService);
  
  SharedPreferences prefs;
  try {
    debugPrint("[LOG] Before AppInitializer.initialize()");
    prefs = await initializer.initialize();
    debugPrint("[LOG] After AppInitializer.initialize()");
  } catch (e) {
    debugPrint("[FATAL STARTUP ERROR] Initialization failed: $e");
    rethrow;
  }

  // Startup validation before runApp()
  try {
    debugPrint("[LOG] Before Startup Validation");
    if (dotenv.env['SUPABASE_URL'] == null || dotenv.env['SUPABASE_URL']!.isEmpty ||
        dotenv.env['SUPABASE_ANON_KEY'] == null || dotenv.env['SUPABASE_ANON_KEY']!.isEmpty) {
      debugPrint("[LOG] SUPABASE_URL or SUPABASE_ANON_KEY is missing/empty");
      throw Exception("Environment variables not loaded.");
    }
    
    // Verify Supabase is initialized
    debugPrint("[LOG] Before verifying Supabase instance");
    final _ = Supabase.instance.client;
    debugPrint("[LOG] After verifying Supabase instance");

    // Verify Isar is initialized (will throw StateError if not initialized)
    debugPrint("[LOG] Before verifying Isar instance");
    final __ = isarService.isar;
    debugPrint("[LOG] After verifying Isar instance");
    debugPrint("[LOG] Startup Validation DONE");
  } catch (e) {
    debugPrint("[FATAL STARTUP VALIDATION ERROR] Startup validation failed: $e");
    throw Exception("Startup validation failed: $e");
  }
  
  debugPrint("[LOG] Before runApp()");
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const FinTrackApp(),
    ),
  );
}

class FinTrackApp extends ConsumerWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final locale = ref.watch(localeProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return settingsAsync.when(
          data: (settings) {
            ColorScheme lightColorScheme;
            ColorScheme darkColorScheme;

            if (settings.dynamicColor && lightDynamic != null && darkDynamic != null) {
              lightColorScheme = lightDynamic.harmonized();
              darkColorScheme = darkDynamic.harmonized();
            } else {
              lightColorScheme = DynamicColorService.getFallbackColorScheme(Brightness.light);
              darkColorScheme = DynamicColorService.getFallbackColorScheme(Brightness.dark);
            }

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'FinTrack',
              theme: ThemeService.getTheme(settings, lightColorScheme),
              darkTheme: ThemeService.getTheme(settings, darkColorScheme),
              themeMode: themeMode,
              routerConfig: router,
              locale: locale,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: LocalizationService.getSupportedLocales(),
              builder: (context, child) {
                return AuthenticationGuard(
                  child: child!,
                );
              },
            );
          },
          loading: () => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', height: 100),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
          error: (err, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: Text('Error: $err')),
            ),
          ),
        );
      },
    );
  }
}
