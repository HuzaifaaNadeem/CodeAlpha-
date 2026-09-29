import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/learning/data/repositories/local_progress_repository.dart';
import 'features/learning/presentation/providers/learning_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        progressRepositoryProvider.overrideWithValue(
          LocalProgressRepository(preferences),
        ),
      ],
      child: const LinguaApp(),
    ),
  );
}
