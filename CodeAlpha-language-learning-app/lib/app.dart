import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/learning/presentation/screens/main_shell.dart';

class LinguaApp extends StatelessWidget {
  const LinguaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lingua',
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}
