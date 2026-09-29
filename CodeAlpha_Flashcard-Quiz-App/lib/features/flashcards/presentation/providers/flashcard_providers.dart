import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_flashcard_data_source.dart';
import '../../data/repositories/hive_flashcard_repository.dart';
import '../../domain/entities/deck.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/quiz_stat.dart';
import '../../domain/repositories/flashcard_repository.dart';

final localDataSourceProvider = Provider<LocalFlashcardDataSource>((ref) {
  return LocalFlashcardDataSource();
});

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  return HiveFlashcardRepository(ref.watch(localDataSourceProvider));
});

final decksProvider = FutureProvider<List<Deck>>((ref) async {
  return ref.watch(flashcardRepositoryProvider).getDecks();
});

final cardsProvider =
    FutureProvider.family<List<Flashcard>, String>((ref, deckId) async {
  return ref.watch(flashcardRepositoryProvider).getCards(deckId);
});

final statsProvider =
    FutureProvider.family<List<QuizStat>, String>((ref, deckId) async {
  return ref.watch(flashcardRepositoryProvider).getStats(deckId);
});
