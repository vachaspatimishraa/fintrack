import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class DynamicColorService {
  static Future<ColorScheme?> getDynamicColorScheme(Brightness brightness) async {
    try {
      final dynamicColors = await DynamicColorPlugin.getCorePalette();
      if (dynamicColors != null) {
        return dynamicColors.toColorScheme(brightness: brightness);
      }
    } catch (e) {
      // Fallback if dynamic color fails
    }
    return null;
  }

  static ColorScheme getFallbackColorScheme(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      surface: brightness == Brightness.light ? AppColors.surface : AppColors.darkSurface,
      error: AppColors.expense,
    );
  }
}
