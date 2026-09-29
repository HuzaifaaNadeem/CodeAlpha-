import 'package:uuid/uuid.dart';

import '../../domain/entities/deck.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/quiz_stat.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/local_flashcard_data_source.dart';
import '../models/deck_model.dart';
import '../models/flashcard_model.dart';
import '../models/quiz_stat_model.dart';
import '../seeds/starter_content.dart';

class HiveFlashcardRepository implements FlashcardRepository {
  HiveFlashcardRepository(this._local, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final LocalFlashcardDataSource _local;
  final Uuid _uuid;

  Future<void> _ensureStarterContent() async {
    final starterContent = buildStarterContent();
    await _local.seedStarterContent(
      decks: starterContent.decks,
      cards: starterContent.cards,
    );
  }

  @override
  Future<List<Deck>> getDecks() async {
    await _ensureStarterContent();
    final models = await _local.getDecks();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Deck> createDeck(String title) async {
    final deck = Deck(
      id: _uuid.v4(),
      title: title.trim(),
      createdAt: DateTime.now(),
    );
    await _local.putDeck(DeckModel.fromEntity(deck));
    return deck;
  }

  @override
  Future<void> deleteDeck(String deckId) => _local.deleteDeck(deckId);

  @override
  Future<List<Flashcard>> getCards(String deckId) async {
    final models = await _local.getCards(deckId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Flashcard>> getAllCards() async {
    await _ensureStarterContent();
    final models = await _local.getAllCards();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Flashcard> createCard({
    required String deckId,
    required String question,
    required String answer,
    required String category,
  }) async {
    final now = DateTime.now();
    final card = Flashcard(
      id: _uuid.v4(),
      deckId: deckId,
      question: question.trim(),
      answer: answer.trim(),
      category: category.trim().isEmpty ? 'General' : category.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _local.putCard(FlashcardModel.fromEntity(card));
    return card;
  }

  @override
  Future<void> updateCard(Flashcard card) {
    return _local.putCard(FlashcardModel.fromEntity(card));
  }

  @override
  Future<void> deleteCard(String cardId) => _local.deleteCard(cardId);

  @override
  Future<void> saveQuizStat(QuizStat stat) {
    return _local.putStat(QuizStatModel.fromEntity(stat));
  }

  @override
  Future<List<QuizStat>> getStats(String deckId) async {
    final models = await _local.getStats(deckId);
    return models.map((model) => model.toEntity()).toList();
  }
}
