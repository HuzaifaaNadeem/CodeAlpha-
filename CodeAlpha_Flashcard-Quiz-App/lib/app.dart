import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/flashcards/presentation/screens/home_screen.dart';

class FlashcardQuizApp extends StatelessWidget {
  const FlashcardQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fliply',
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
