import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'features/quotes/presentation/screens/home_screen.dart';

class QuoteSparkApp extends StatelessWidget {
  const QuoteSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.canvas,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: AppTheme.outline,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QuoteSpark',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
