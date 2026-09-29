import 'dart:math';

import 'package:flashcard_quiz_app/features/flashcards/domain/entities/flashcard.dart';
import 'package:flashcard_quiz_app/features/flashcards/domain/services/mcq_quiz_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Flashcard card({
    required String id,
    required String deckId,
    required String answer,
    String category = 'Test',
  }) {
    final now = DateTime(2026, 1, 1);
    return Flashcard(
      id: id,
      deckId: deckId,
      question: 'Question $id?',
      answer: answer,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('generates four distinct options with exactly one correct answer', () {
    final cards = [
      card(id: '1', deckId: 'deck', answer: 'Alpha'),
      card(id: '2', deckId: 'deck', answer: 'Beta'),
      card(id: '3', deckId: 'deck', answer: 'Gamma'),
      card(id: '4', deckId: 'deck', answer: 'Delta'),
    ];

    final questions = McqQuizGenerator(random: Random(7)).generate(
      deckCards: cards,
      allCards: cards,
    );

    expect(questions, hasLength(4));
    for (final question in questions) {
      expect(question.options, hasLength(4));
      expect(question.options.toSet(), hasLength(4));
      expect(
        question.options.where(question.isCorrect),
        hasLength(1),
      );
    }
  });

  test('uses the wider library when a deck has too few distractors', () {
    final smallDeck = [
      card(id: '1', deckId: 'small', answer: 'Alpha', category: 'Shared'),
    ];
    final library = [
      ...smallDeck,
      card(id: '2', deckId: 'other', answer: 'Beta', category: 'Shared'),
      card(id: '3', deckId: 'other', answer: 'Gamma', category: 'Shared'),
      card(id: '4', deckId: 'other', answer: 'Delta', category: 'Shared'),
    ];

    final questions = McqQuizGenerator(random: Random(9)).generate(
      deckCards: smallDeck,
      allCards: library,
    );

    expect(questions, hasLength(1));
    expect(questions.single.options.toSet(), hasLength(4));
    expect(questions.single.options, contains('Alpha'));
  });
}
