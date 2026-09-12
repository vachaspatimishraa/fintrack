import 'package:flutter/material.dart';
import 'package:fintrack/core/constants/colors.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';

class ThemeService {
  static ThemeData getTheme(SettingsEntity settings, ColorScheme colorScheme) {
    final bool isDark = colorScheme.brightness == Brightness.dark;
    final bool isAmoled = isDark && settings.amoledMode;
    
    // Handle AMOLED mode and consistent surfaces
    final Color surfaceColor = isAmoled 
        ? Colors.black 
        : colorScheme.surface;

    final Color scaffoldBackgroundColor = isAmoled
        ? Colors.black
        : (isDark ? AppColors.darkBackground : AppColors.background);

    final ColorScheme activeColorScheme = colorScheme.copyWith(
      surface: surfaceColor,
      surfaceContainer: isAmoled ? Colors.black : colorScheme.surfaceContainer,
      surfaceContainerHigh: isAmoled ? Colors.black : colorScheme.surfaceContainerHigh,
      surfaceContainerHighest: isAmoled ? Colors.black : colorScheme.surfaceContainerHighest,
      surfaceContainerLow: isAmoled ? Colors.black : colorScheme.surfaceContainerLow,
      surfaceContainerLowest: isAmoled ? Colors.black : colorScheme.surfaceContainerLowest,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: activeColorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: activeColorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: activeColorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: isAmoled ? 0 : (isDark ? 0 : 1),
        shadowColor: Colors.black.withValues(alpha: 0.03),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isAmoled ? Colors.grey.shade900 : activeColorScheme.outlineVariant, 
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
            color: activeColorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: activeColorScheme.outlineVariant,
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
          foregroundColor: activeColorScheme.onPrimary,
          elevation: 2,
          shadowColor: activeColorScheme.primary.withValues(alpha: 0.2),
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
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: activeColorScheme.outlineVariant,
        thickness: 1.0,
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
