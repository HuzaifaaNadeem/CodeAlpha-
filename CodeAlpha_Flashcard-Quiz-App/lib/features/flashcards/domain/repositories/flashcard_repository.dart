import '../entities/deck.dart';
import '../entities/flashcard.dart';
import '../entities/quiz_stat.dart';

abstract interface class FlashcardRepository {
  Future<List<Deck>> getDecks();
  Future<Deck> createDeck(String title);
  Future<void> deleteDeck(String deckId);

  Future<List<Flashcard>> getCards(String deckId);
  Future<List<Flashcard>> getAllCards();
  Future<Flashcard> createCard({
    required String deckId,
    required String question,
    required String answer,
    required String category,
  });
  Future<void> updateCard(Flashcard card);
  Future<void> deleteCard(String cardId);

  Future<void> saveQuizStat(QuizStat stat);
  Future<List<QuizStat>> getStats(String deckId);
}
