import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  
  final isarService = IsarInitializationService();
  final supabaseService = SupabaseConfigService();
  final initializer = AppInitializer(isarService, supabaseService);
  
  final prefs = await initializer.initialize();
  
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
