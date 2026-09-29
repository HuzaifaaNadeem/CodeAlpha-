import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Signature palette: warm white canvas, deep ink, restrained indigo accents.
  static const Color primary = Color(0xFF6558E8);
  static const Color primaryDark = Color(0xFF4036B2);
  static const Color primaryLight = Color(0xFF9389F2);
  static const Color ink = Color(0xFF171821);
  static const Color mutedInk = Color(0xFF747683);
  static const Color canvas = Color(0xFFFAF9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF2F0F8);
  static const Color surfaceWarm = Color(0xFFFFFCF8);
  static const Color outline = Color(0xFFE9E7EF);
  static const Color outlineStrong = Color(0xFFDCD9E5);

  static const Color coral = Color(0xFFE86D67);
  static const Color amber = Color(0xFFDDA23A);
  static const Color mint = Color(0xFF2FA581);
  static const Color sky = Color(0xFF438ED2);
  static const Color rose = Color(0xFFB96598);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7468EE), Color(0xFF5042CC)],
  );

  static const LinearGradient softBrandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF2F0FF), Color(0xFFFFFCFA)],
  );

  static const List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: Color(0x0D171821),
      blurRadius: 32,
      offset: Offset(0, 14),
    ),
    BoxShadow(
      color: Color(0x06171821),
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
    ).copyWith(
      primary: primary,
      secondary: coral,
      surface: surface,
      onSurface: ink,
      outline: outlineStrong,
      outlineVariant: outline,
      surfaceContainerLowest: surface,
      surfaceContainerLow: canvas,
      surfaceContainer: surfaceSoft,
    );

    const textTheme = TextTheme(
      displayMedium: TextStyle(
        fontSize: 42,
        height: 1.04,
        letterSpacing: -1.7,
        fontWeight: FontWeight.w800,
        color: ink,
      ),
      displaySmall: TextStyle(
        fontSize: 34,
        height: 1.08,
        letterSpacing: -1.2,
        fontWeight: FontWeight.w800,
        color: ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        height: 1.2,
        letterSpacing: -0.7,
        fontWeight: FontWeight.w800,
        color: ink,
      ),
      headlineSmall: TextStyle(
        fontSize: 23,
        height: 1.22,
        letterSpacing: -0.4,
        fontWeight: FontWeight.w800,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        height: 1.28,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.34,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.56,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: mutedInk,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      fontFamily: 'Segoe UI',
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: outline),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          backgroundColor: Colors.white,
          side: const BorderSide(color: outline),
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          highlightColor: primary.withValues(alpha: 0.07),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        insetPadding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        prefixIconColor: mutedInk,
        hintStyle: const TextStyle(color: mutedInk),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ink,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
