import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/core/constants/colors.dart';
import 'package:fintrack/core/database/isar/collections/settings_model.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';
import 'package:fintrack/features/settings/domain/services/theme_service.dart';
import 'package:fintrack/features/settings/providers/settings_provider.dart';

void main() {
  group('Appearance Settings & System Theming', () {
    test('SettingsEntity defaults to system theme', () {
      final settings = SettingsEntity();
      expect(settings.themeMode, equals('system'));
    });

    test('SettingsModel defaults to system theme', () {
      final model = SettingsModel();
      expect(model.themeMode, equals('system'));
    });

    test('themeModeProvider returns ThemeMode.system by default', () {
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith((ref) => Stream.value(SettingsEntity())),
        ],
      );
      addTearDown(container.dispose);

      final mode = container.read(themeModeProvider);
      expect(mode, equals(ThemeMode.system));
    });

    test('themeModeProvider maps settings strings correctly', () async {
      final testCases = {
        'system': ThemeMode.system,
        'light': ThemeMode.light,
        'dark': ThemeMode.dark,
        'amoled': ThemeMode.dark,
        'unknown': ThemeMode.system,
      };

      for (final entry in testCases.entries) {
        final container = ProviderContainer(
          overrides: [
            settingsProvider.overrideWith(
              (ref) => Stream.value(SettingsEntity(themeMode: entry.key)),
            ),
          ],
        );
        await container.read(settingsProvider.future);
        expect(
          container.read(themeModeProvider),
          equals(entry.value),
          reason: 'Expected ${entry.key} to map to ${entry.value}',
        );
        container.dispose();
      }
    });

    test('ThemeService should return black background for AMOLED mode', () {
      final settings = SettingsEntity(amoledMode: true, themeMode: 'amoled');
      final colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      );

      final themeData = ThemeService.getTheme(settings, colorScheme);

      expect(themeData.scaffoldBackgroundColor, Colors.black);
      expect(themeData.colorScheme.surface, Colors.black);
    });

    test('ThemeService should return standard background for non-AMOLED dark mode', () {
      final settings = SettingsEntity(amoledMode: false, themeMode: 'dark');
      final colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      );

      final themeData = ThemeService.getTheme(settings, colorScheme);

      expect(themeData.scaffoldBackgroundColor, isNot(Colors.black));
      expect(themeData.scaffoldBackgroundColor, equals(AppColors.darkBackground));
    });

    test('ThemeService should return clean off-white background for light mode', () {
      final settings = SettingsEntity(themeMode: 'light');
      final colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      );

      final themeData = ThemeService.getTheme(settings, colorScheme);

      expect(themeData.scaffoldBackgroundColor, equals(AppColors.background));
      expect(themeData.cardTheme.color, equals(colorScheme.surface));
    });
  });
}

