import 'package:flashcard_quiz_app/features/flashcards/domain/entities/flashcard.dart';
import 'package:flashcard_quiz_app/features/flashcards/domain/entities/mcq_question.dart';
import 'package:flashcard_quiz_app/features/flashcards/presentation/providers/mcq_quiz_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 1, 1);
  final card = Flashcard(
    id: 'card-1',
    deckId: 'deck-1',
    question: 'What is 2 + 2?',
    answer: '4',
    category: 'Math',
    createdAt: now,
    updatedAt: now,
  );
  final question = McqQuestion(
    card: card,
    options: const ['2', '3', '4', '5'],
  );

  test('locks an answer, scores it, and advances after next', () {
    final controller = McqQuizController();

    controller.selectAnswer(question: question, answer: '4');
    expect(controller.state.correct, 1);
    expect(controller.state.incorrect, 0);
    expect(controller.state.selectedAnswer, '4');
    expect(controller.state.attempts, hasLength(1));

    controller.next(totalQuestions: 2);
    expect(controller.state.index, 1);
    expect(controller.state.selectedAnswer, isNull);
    expect(controller.state.finished, isFalse);
  });

  test('marks the session finished after the last answered question', () {
    final controller = McqQuizController();

    controller.selectAnswer(question: question, answer: '3');
    expect(controller.state.correct, 0);
    expect(controller.state.incorrect, 1);

    controller.next(totalQuestions: 1);
    expect(controller.state.finished, isTrue);
    expect(controller.state.attempts.single.isCorrect, isFalse);
  });
}
