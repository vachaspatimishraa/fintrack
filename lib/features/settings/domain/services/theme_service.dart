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
        elevation: isDark && settings.amoledMode ? 0 : 2,
        shadowColor: Colors.black.withOpacity(0.03),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: activeColorScheme.primary, 
            width: 2.0,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: activeColorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: activeColorScheme.primary.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide.none,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
