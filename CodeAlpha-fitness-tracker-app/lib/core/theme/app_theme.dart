import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const canvas = Color(0xFFF5F7F4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF0F4F1);
  static const ink = Color(0xFF101A18);
  static const muted = Color(0xFF65716D);
  static const outline = Color(0xFFE0E6E2);
  static const primary = Color(0xFF176B5B);
  static const primaryDark = Color(0xFF0E4F43);
  static const mint = Color(0xFF9CE8C8);
  static const lime = Color(0xFFC9F36B);
  static const blue = Color(0xFF5E84F2);
  static const coral = Color(0xFFF57D6C);
  static const amber = Color(0xFFF4B84A);

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: mint,
      onSecondary: ink,
      surface: surface,
      onSurface: ink,
      error: coral,
      outline: outline,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: base.textTheme.copyWith(
        displaySmall: const TextStyle(
          color: ink,
          fontSize: 36,
          height: 1.05,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.3,
        ),
        headlineMedium: const TextStyle(
          color: ink,
          fontSize: 28,
          height: 1.1,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineSmall: const TextStyle(
          color: ink,
          fontSize: 22,
          height: 1.15,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        titleLarge: const TextStyle(
          color: ink,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: const TextStyle(
          color: ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: const TextStyle(
          color: ink,
          fontSize: 15,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: const TextStyle(
          color: muted,
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: const TextStyle(
          color: ink,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: mint.withValues(alpha: 0.55),
        height: 72,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.3),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(color: outline, thickness: 1),
    );
  }
}
