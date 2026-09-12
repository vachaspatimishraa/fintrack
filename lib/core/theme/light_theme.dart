import 'package:flutter/material.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';
import 'package:fintrack/features/settings/domain/services/dynamic_color_service.dart';
import 'package:fintrack/features/settings/domain/services/theme_service.dart';

ThemeData get lightTheme => ThemeService.getTheme(
      SettingsEntity(themeMode: 'light'),
      DynamicColorService.getFallbackColorScheme(Brightness.light),
    );
