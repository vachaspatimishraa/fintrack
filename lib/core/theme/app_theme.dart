import 'package:flutter/material.dart';
import 'package:fintrack/core/theme/light_theme.dart';
import 'package:fintrack/core/theme/dark_theme.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;
}
