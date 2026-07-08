import 'package:flutter/material.dart';
import '../../domain/entities/settings_entity.dart';

class ThemeService {
  static ThemeData getTheme(SettingsEntity settings, ColorScheme colorScheme) {
    final bool isDark = colorScheme.brightness == Brightness.dark;
    
    // Handle AMOLED mode
    final Color backgroundColor = (isDark && settings.amoledMode) 
        ? Colors.black 
        : colorScheme.surface;
    final Color surfaceColor = (isDark && settings.amoledMode) 
        ? Colors.black 
        : colorScheme.surface;

    // Apply High Contrast adjustments
    ColorScheme activeColorScheme = colorScheme;
    if (settings.highContrast) {
      activeColorScheme = colorScheme.copyWith(
        outline: isDark ? Colors.white : Colors.black,
        outlineVariant: isDark ? Colors.white70 : Colors.black87,
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: activeColorScheme.copyWith(
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: settings.highContrast ? 1 : 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: settings.highContrast ? FontWeight.bold : FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: isDark && settings.amoledMode ? 0 : 1,
        shadowColor: Colors.black.withOpacity(0.04),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: settings.highContrast 
                ? (isDark ? Colors.white : Colors.black) 
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200), 
            width: settings.highContrast ? 2.0 : 1.0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: settings.highContrast 
                ? (isDark ? Colors.white : Colors.black) 
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: settings.highContrast ? 2.0 : 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: settings.highContrast 
                ? (isDark ? Colors.white : Colors.black) 
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: settings.highContrast ? 2.0 : 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: activeColorScheme.primary, 
            width: settings.highContrast ? 3.0 : 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: activeColorScheme.primary,
          foregroundColor: activeColorScheme.onPrimary,
          elevation: settings.highContrast ? 2 : 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: settings.highContrast 
                ? BorderSide(color: activeColorScheme.onPrimary, width: 2) 
                : BorderSide.none,
          ),
          textStyle: TextStyle(
            fontWeight: settings.highContrast ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
      visualDensity: _getVisualDensity(settings.displayDensity),
    );
  }

  static VisualDensity _getVisualDensity(String density) {
    switch (density) {
      case 'compact':
        return VisualDensity.compact;
      case 'expanded':
        return const VisualDensity(horizontal: 2, vertical: 2);
      default:
        return VisualDensity.comfortable;
    }
  }

  static double getFontScale(String scale) {
    switch (scale) {
      case 'small':
        return 0.8;
      case 'large':
        return 1.2;
      case 'extra_large':
        return 1.4;
      default:
        return 1.0;
    }
  }
}
