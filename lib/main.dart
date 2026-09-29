import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/flashcards/data/models/deck_model.dart';
import 'features/flashcards/data/models/flashcard_model.dart';
import 'features/flashcards/data/models/quiz_stat_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(DeckModelAdapter.typeIdValue)) {
    Hive.registerAdapter(DeckModelAdapter());
  }
  if (!Hive.isAdapterRegistered(FlashcardModelAdapter.typeIdValue)) {
    Hive.registerAdapter(FlashcardModelAdapter());
  }
  if (!Hive.isAdapterRegistered(QuizStatModelAdapter.typeIdValue)) {
    Hive.registerAdapter(QuizStatModelAdapter());
  }

  runApp(const ProviderScope(child: FlashcardQuizApp()));
}
