import 'package:flutter/material.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';
import 'package:fintrack/features/settings/domain/services/dynamic_color_service.dart';
import 'package:fintrack/features/settings/domain/services/theme_service.dart';

ThemeData get darkTheme => ThemeService.getTheme(
      SettingsEntity(themeMode: 'dark'),
      DynamicColorService.getFallbackColorScheme(Brightness.dark),
    );
