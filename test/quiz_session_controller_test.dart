import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_quiz_app/features/flashcards/presentation/providers/quiz_session_provider.dart';

void main() {
  group('QuizSessionController', () {
    test('reveals answer before allowing assessment', () {
      final controller = QuizSessionController();

      controller.markAnswer(remembered: true, totalCards: 2);
      expect(controller.state.correct, 0);
      expect(controller.state.index, 0);

      controller.revealAnswer();
      expect(controller.state.answerRevealed, isTrue);
    });

    test('tracks remembered and forgotten answers and completes quiz', () {
      final controller = QuizSessionController();

      controller.revealAnswer();
      controller.markAnswer(remembered: true, totalCards: 2);
      expect(controller.state.correct, 1);
      expect(controller.state.incorrect, 0);
      expect(controller.state.index, 1);
      expect(controller.state.finished, isFalse);

      controller.revealAnswer();
      controller.markAnswer(remembered: false, totalCards: 2);
      expect(controller.state.correct, 1);
      expect(controller.state.incorrect, 1);
      expect(controller.state.finished, isTrue);
    });
  });
}
