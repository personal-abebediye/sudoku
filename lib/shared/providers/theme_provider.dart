import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme options
enum AppThemeMode {
  light,
  dark,
  darkModern, // New modern dark theme from design
  highContrast,
  system,
}

/// Theme mode provider
final themeModeProvider =
    StateProvider<AppThemeMode>((ref) => AppThemeMode.darkModern);

/// Extension to convert AppThemeMode to Material ThemeMode
extension AppThemeModeExtension on AppThemeMode {
  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.darkModern:
        return ThemeMode.dark;
      case AppThemeMode.highContrast:
        return ThemeMode.light; // Use light mode for high contrast
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
