import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/fitness/presentation/screens/root_shell.dart';

class PulseFitApp extends StatelessWidget {
  const PulseFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulseFit MAX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const RootShell(),
    );
  }
}
