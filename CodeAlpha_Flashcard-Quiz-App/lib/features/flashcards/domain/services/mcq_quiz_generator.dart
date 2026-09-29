import 'dart:math';

import '../entities/flashcard.dart';
import '../entities/mcq_question.dart';

/// Builds four-option MCQs from ordinary question/answer flashcards.
///
/// Distractors are selected in this order:
/// 1. Other answers from the same deck.
/// 2. Answers with the same category from the wider library.
/// 3. Any other answer in the local library.
///
/// This keeps choices relevant while still allowing very small custom decks to
/// participate in MCQ mode when the broader library has enough distinct data.
class McqQuizGenerator {
  McqQuizGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<McqQuestion> generate({
    required List<Flashcard> deckCards,
    required List<Flashcard> allCards,
    int maxQuestions = 10,
  }) {
    if (deckCards.isEmpty) {
      return const [];
    }

    final shuffledCards = [...deckCards]..shuffle(_random);
    final sourceCards =
        shuffledCards.take(min(maxQuestions, shuffledCards.length));
    final questions = <McqQuestion>[];

    for (final source in sourceCards) {
      final distractors = <String>[];
      final seen = <String>{_normalise(source.answer)};

      void addCandidates(Iterable<Flashcard> candidates) {
        final shuffled = [...candidates]..shuffle(_random);
        for (final candidate in shuffled) {
          if (candidate.id == source.id) {
            continue;
          }

          final answer = candidate.answer.trim();
          final key = _normalise(answer);
          if (answer.isEmpty || seen.contains(key)) {
            continue;
          }

          seen.add(key);
          distractors.add(answer);
          if (distractors.length == 3) {
            return;
          }
        }
      }

      addCandidates(deckCards);

      if (distractors.length < 3) {
        addCandidates(
          allCards.where(
            (card) =>
                card.deckId != source.deckId &&
                _normalise(card.category) == _normalise(source.category),
          ),
        );
      }

      if (distractors.length < 3) {
        addCandidates(allCards);
      }

      // A valid MCQ needs exactly four distinct visible choices.
      if (distractors.length < 3) {
        continue;
      }

      final options = <String>[
        source.answer.trim(),
        ...distractors.take(3),
      ]..shuffle(_random);

      questions.add(
        McqQuestion(
          card: source,
          options: List.unmodifiable(options),
        ),
      );
    }

    return List.unmodifiable(questions);
  }

  String _normalise(String value) => value.trim().toLowerCase();
}
