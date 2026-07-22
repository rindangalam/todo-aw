import 'package:flutter/material.dart';

import 'design/light_theme.dart';
import 'design/dark_theme.dart';

@Deprecated('Use LightTheme.theme / DarkTheme.theme from core/design/ instead')
class AppColors {
  static const primary = Color(0xFF5865F2);
  static const primaryDark = Color(0xFF5865F2);
  static const secondary = Color(0xFF7C3AED);
  static const secondaryDark = Color(0xFF7C3AED);
  static const error = Color(0xFFEF4444);
  static const errorDark = Color(0xFFEF4444);
  static const priorityP1 = Color(0xFFEF4444);
  static const priorityP2 = Color(0xFFF59E0B);
  static const priorityP3 = Color(0xFF3B82F6);
  static const priorityP4 = Color(0xFF9CA3AF);
}

@Deprecated('Use LightTheme.theme / DarkTheme.theme from core/design/ instead')
class AppTheme {
  static ThemeData get light => LightTheme.theme;
  static ThemeData get dark => DarkTheme.theme;
}
