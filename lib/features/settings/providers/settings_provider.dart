import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/splash/providers/initialization_provider.dart';
import 'package:fintrack/core/utils/formatter.dart';
import 'package:fintrack/features/settings/data/datasources/local/settings_local_datasource.dart';
import 'package:fintrack/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';
import 'package:fintrack/features/settings/domain/repositories/settings_repository.dart';
import 'package:fintrack/features/settings/domain/repositories/settings_remote_datasource.dart';
import 'package:fintrack/features/settings/domain/services/theme_service.dart';
import 'package:fintrack/features/settings/domain/services/dynamic_color_service.dart';
import 'package:fintrack/features/settings/domain/services/localization_service.dart';
import 'package:fintrack/features/settings/providers/backup_provider.dart';
import 'package:fintrack/features/settings/providers/security_provider.dart';

import 'package:fintrack/features/settings/data/datasources/remote/settings_remote_datasource_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final settingsLocalDatasourceProvider = Provider<SettingsLocalDatasource>((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  return SettingsLocalDatasource(isarService.isar);
});

final settingsRemoteDatasourceProvider = Provider<SettingsRemoteDatasource>((ref) {
  return SettingsRemoteDatasourceImpl(Supabase.instance.client);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final localDatasource = ref.watch(settingsLocalDatasourceProvider);
  final remoteDatasource = ref.watch(settingsRemoteDatasourceProvider);
  final backupRepository = ref.watch(backupRepositoryProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  
  return SettingsRepositoryImpl(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    backupRepository: backupRepository,
    secureStorage: secureStorage,
  );
});

final settingsProvider = StreamProvider<SettingsEntity>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchSettings().map((settings) {
    AppFormatter.currentCurrency = settings.currency;
    AppFormatter.currentLanguage = settings.language;
    return settings;
  });
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.maybeWhen(
    data: (settings) {
      switch (settings.themeMode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
        case 'amoled':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    },
    orElse: () => ThemeMode.system,
  );
});

final appThemeProvider = Provider.family<ThemeData, Brightness>((ref, brightness) {
  final settingsAsync = ref.watch(settingsProvider);
  final settings = settingsAsync.maybeWhen(
    data: (s) => s,
    orElse: SettingsEntity.new,
  );

  final colorScheme = DynamicColorService.getFallbackColorScheme(brightness);
  return ThemeService.getTheme(settings, colorScheme);
});

final localeProvider = Provider<Locale>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.maybeWhen(
    data: LocalizationService.getLocale,
    orElse: () => const Locale('en'),
  );
});
