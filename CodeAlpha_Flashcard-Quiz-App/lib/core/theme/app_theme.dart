import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color purple = Color(0xFF6C5CE7);
  static const Color purpleDark = Color(0xFF4D3FD1);
  static const Color blue = Color(0xFF4D96FF);
  static const Color cyan = Color(0xFF45D6D6);
  static const Color yellow = Color(0xFFFFD166);
  static const Color orange = Color(0xFFFF9F43);
  static const Color pink = Color(0xFFFF7AA2);
  static const Color green = Color(0xFF43C59E);
  static const Color red = Color(0xFFFF6B6B);
  static const Color ink = Color(0xFF242338);
  static const Color mutedInk = Color(0xFF77758A);
  static const Color background = Color(0xFFF7F8FC);

  static const Color successLight = Color(0xFFE3F8EF);
  static const Color errorLight = Color(0xFFFFE9E9);

  static const List<Color> deckColors = <Color>[
    Color(0xFFEDE9FF),
    Color(0xFFE4F2FF),
    Color(0xFFFFF1CB),
    Color(0xFFFFE6EF),
    Color(0xFFDFF7F1),
    Color(0xFFFFEBDD),
  ];

  static const List<Color> deckAccents = <Color>[
    purple,
    blue,
    orange,
    pink,
    green,
    Color(0xFFEF7B45),
  ];

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: purple,
      brightness: Brightness.light,
      surface: Colors.white,
    ).copyWith(
      primary: purple,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEDE9FF),
      onPrimaryContainer: ink,
      secondary: blue,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE4F2FF),
      onSecondaryContainer: ink,
      tertiary: orange,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFF1CB),
      onTertiaryContainer: ink,
      error: red,
      onError: Colors.white,
      errorContainer: errorLight,
      onErrorContainer: const Color(0xFF8E2A2A),
      onSurface: ink,
      onSurfaceVariant: mutedInk,
      outline: const Color(0xFFD8DAE6),
      outlineVariant: const Color(0xFFE8E9F0),
      shadow: const Color(0xFF17152A),
      scrim: const Color(0xFF17152A),
      inverseSurface: ink,
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFFC7C0FF),
      surfaceTint: Colors.transparent,
    );

    final baseText = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: baseText.copyWith(
        displaySmall: const TextStyle(
          color: ink,
          fontSize: 36,
          height: 1.08,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.4,
        ),
        headlineMedium: const TextStyle(
          color: ink,
          fontSize: 28,
          height: 1.15,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
        headlineSmall: const TextStyle(
          color: ink,
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        titleLarge: const TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.35,
        ),
        titleMedium: const TextStyle(
          color: ink,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: const TextStyle(
          color: ink,
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: const TextStyle(
          color: mutedInk,
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 21,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelStyle:
            const TextStyle(color: mutedInk, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: Color(0xFFA5A4B2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5E6EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5E6EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: purple, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: red, width: 1.8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: Color(0xFFDEDFE9), width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: StadiumBorder(),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: purple,
        linearTrackColor: Color(0xFFE9E7F5),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
