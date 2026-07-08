import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/settings/domain/services/theme_service.dart';
import 'features/settings/domain/services/dynamic_color_service.dart';
import 'features/settings/domain/services/localization_service.dart';

import 'features/settings/presentation/widgets/authentication_guard.dart';
import 'features/splash/providers/initialization_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: FinTrackApp(),
    ),
  );
}

class FinTrackApp extends ConsumerWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initAsync = ref.watch(appInitializationProvider);

    return initAsync.when(
      data: (prefs) {
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
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.linear(ThemeService.getFontScale(settings.fontScale)),
                        ),
                        child: child!,
                      ),
                    );
                  },
                );
              },
              loading: () => const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
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
      },
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Initialization Error: $err'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(appInitializationProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
