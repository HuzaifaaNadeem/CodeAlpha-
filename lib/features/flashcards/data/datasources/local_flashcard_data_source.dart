import 'package:hive/hive.dart';

import '../models/deck_model.dart';
import '../models/flashcard_model.dart';
import '../models/quiz_stat_model.dart';

class LocalFlashcardDataSource {
  static const _decksBoxName = 'decks';
  static const _cardsBoxName = 'flashcards';
  static const _statsBoxName = 'quiz_stats';
  static const _metadataBoxName = 'flashcard_metadata';
  static const _starterSeededKey = 'starter_content_seeded_v1';

  Future<Box<DeckModel>> _decks() => Hive.openBox<DeckModel>(_decksBoxName);
  Future<Box<FlashcardModel>> _cards() =>
      Hive.openBox<FlashcardModel>(_cardsBoxName);
  Future<Box<QuizStatModel>> _stats() =>
      Hive.openBox<QuizStatModel>(_statsBoxName);
  Future<Box<dynamic>> _metadata() => Hive.openBox<dynamic>(_metadataBoxName);

  /// Seeds the built-in decks exactly once for this local installation.
  ///
  /// Deterministic starter IDs plus [putAll] make this operation idempotent.
  /// The metadata flag is only written after all starter data is persisted.
  Future<void> seedStarterContent({
    required List<DeckModel> decks,
    required List<FlashcardModel> cards,
  }) async {
    final metadataBox = await _metadata();
    final alreadySeeded = metadataBox.get(_starterSeededKey) == true;

    if (alreadySeeded) {
      return;
    }

    final deckBox = await _decks();
    final cardBox = await _cards();

    // Remove the old placeholder deck from earlier app versions only when the
    // user never added a card to it. This keeps genuine user content safe.
    final unusedPlaceholderIds = deckBox.values
        .where((deck) => deck.title == 'My First Deck')
        .where(
          (deck) => !cardBox.values.any((card) => card.deckId == deck.id),
        )
        .map((deck) => deck.id)
        .toList();
    await deckBox.deleteAll(unusedPlaceholderIds);

    await deckBox.putAll({for (final deck in decks) deck.id: deck});
    await cardBox.putAll({for (final card in cards) card.id: card});
    await metadataBox.put(_starterSeededKey, true);
  }

  Future<List<DeckModel>> getDecks() async {
    final box = await _decks();
    final decks = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return decks;
  }

  Future<void> putDeck(DeckModel deck) async {
    final box = await _decks();
    await box.put(deck.id, deck);
  }

  Future<void> deleteDeck(String deckId) async {
    final deckBox = await _decks();
    final cardBox = await _cards();
    final statBox = await _stats();

    await deckBox.delete(deckId);

    final cardKeys = cardBox.keys
        .where((key) => cardBox.get(key)?.deckId == deckId)
        .toList();
    await cardBox.deleteAll(cardKeys);

    final statKeys = statBox.keys
        .where((key) => statBox.get(key)?.deckId == deckId)
        .toList();
    await statBox.deleteAll(statKeys);
  }

  Future<List<FlashcardModel>> getCards(String deckId) async {
    final box = await _cards();
    final cards = box.values.where((card) => card.deckId == deckId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return cards;
  }

  Future<List<FlashcardModel>> getAllCards() async {
    final box = await _cards();
    final cards = box.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return cards;
  }

  Future<void> putCard(FlashcardModel card) async {
    final box = await _cards();
    await box.put(card.id, card);
  }

  Future<void> deleteCard(String cardId) async {
    final box = await _cards();
    await box.delete(cardId);
  }

  Future<void> putStat(QuizStatModel stat) async {
    final box = await _stats();
    await box.put(stat.id, stat);
  }

  Future<List<QuizStatModel>> getStats(String deckId) async {
    final box = await _stats();
    final stats = box.values.where((stat) => stat.deckId == deckId).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return stats;
  }
}
