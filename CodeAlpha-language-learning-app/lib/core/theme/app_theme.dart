import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF18232A);
  static const muted = Color(0xFF6B7780);
  static const canvas = Color(0xFFF7F8F4);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF5B55E7);
  static const primaryDark = Color(0xFF403AB8);
  static const mint = Color(0xFFBEE9D0);
  static const mintStrong = Color(0xFF2C9A67);
  static const coral = Color(0xFFFF8B7B);
  static const yellow = Color(0xFFFFD96A);
  static const blue = Color(0xFF81B6F4);
  static const outline = Color(0xFFE6E9E3);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
    ).copyWith(
      primary: primary,
      secondary: mintStrong,
      surface: surface,
      onSurface: ink,
      outline: outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: canvas,
      colorScheme: scheme,
      fontFamily: 'Arial',
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: ink,
          fontSize: 34,
          height: 1.08,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.1,
        ),
        headlineMedium: TextStyle(
          color: ink,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        headlineSmall: TextStyle(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: ink,
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: muted,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFECEBFF),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
