import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';
import 'package:fintrack/features/settings/domain/services/theme_service.dart';

void main() {
  group('Appearance Settings', () {
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
    });

    test('Font scale should be correct', () {
      expect(ThemeService.getFontScale('small'), 0.8);
      expect(ThemeService.getFontScale('default'), 1.0);
      expect(ThemeService.getFontScale('extra_large'), 1.4);
    });
  });
}
