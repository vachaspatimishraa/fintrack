import 'package:flutter/material.dart';
import '../../domain/entities/settings_entity.dart';

class ThemeService {
  static ThemeData getTheme(SettingsEntity settings, ColorScheme colorScheme) {
    final bool isDark = colorScheme.brightness == Brightness.dark;
    
    // Handle AMOLED mode and consistent surfaces
    final Color surfaceColor = (isDark && settings.amoledMode) 
        ? Colors.black 
        : colorScheme.surface;

    ColorScheme activeColorScheme = colorScheme.copyWith(
      surface: surfaceColor,
      surfaceContainer: (isDark && settings.amoledMode) ? Colors.black : colorScheme.surfaceContainer,
      surfaceContainerHigh: (isDark && settings.amoledMode) ? Colors.black : colorScheme.surfaceContainerHigh,
      surfaceContainerHighest: (isDark && settings.amoledMode) ? Colors.black : colorScheme.surfaceContainerHighest,
      surfaceContainerLow: (isDark && settings.amoledMode) ? Colors.black : colorScheme.surfaceContainerLow,
      surfaceContainerLowest: (isDark && settings.amoledMode) ? Colors.black : colorScheme.surfaceContainerLowest,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: activeColorScheme.copyWith(
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: surfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
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
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, 
            width: 1.0,
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
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: activeColorScheme.primary, 
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: activeColorScheme.primary,
          foregroundColor: activeColorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide.none,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.normal,
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
}
