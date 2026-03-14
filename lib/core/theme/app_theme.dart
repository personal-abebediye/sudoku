import 'package:flutter/material.dart';

// ignore_for_file: avoid_redundant_argument_values

/// App theme configuration
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Modern Dark Theme Colors (from Tailwind config)
  static const Color primary = Color(0xFF137FEC); // Blue primary
  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color backgroundDark = Color(0xFF0A0A0A); // Deep black
  static const Color charcoal = Color(0xFF1C1C1E);
  static const Color influence =
      Color(0x26933AEA); // Subtle prominent purple (15% opacity)
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color mutedGray = Color(0xFF3A3A5C);

  /// Light theme
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );

  /// Dark theme
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );

  /// Modern dark theme with custom colors (from Tailwind config)
  static ThemeData get darkModernTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          onPrimary: backgroundDark,
          secondary: charcoal,
          onSecondary: pureWhite,
          surface: backgroundDark,
          onSurface: pureWhite,
          error: Color(0xFFFF5252),
          onError: pureWhite,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: backgroundDark,
          foregroundColor: pureWhite,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: charcoal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: charcoal,
            foregroundColor: pureWhite,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: primary,
            foregroundColor: pureWhite,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: pureWhite, fontFamily: 'Inter'),
          bodyMedium: TextStyle(color: pureWhite, fontFamily: 'Inter'),
          bodySmall: TextStyle(color: pureWhite, fontFamily: 'Inter'),
          titleLarge: TextStyle(color: pureWhite, fontFamily: 'Inter'),
          titleMedium: TextStyle(color: pureWhite, fontFamily: 'Inter'),
          titleSmall: TextStyle(color: pureWhite, fontFamily: 'Inter'),
        ),
      );

  /// High contrast theme for accessibility
  static ThemeData get highContrastTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.highContrastLight(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
      );
}
