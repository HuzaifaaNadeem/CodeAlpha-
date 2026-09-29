import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizSessionState {
  const QuizSessionState({
    required this.index,
    required this.correct,
    required this.incorrect,
    required this.answerRevealed,
    required this.startedAt,
    required this.finished,
  });

  factory QuizSessionState.initial() => QuizSessionState(
        index: 0,
        correct: 0,
        incorrect: 0,
        answerRevealed: false,
        startedAt: DateTime.now(),
        finished: false,
      );

  final int index;
  final int correct;
  final int incorrect;
  final bool answerRevealed;
  final DateTime startedAt;
  final bool finished;

  QuizSessionState copyWith({
    int? index,
    int? correct,
    int? incorrect,
    bool? answerRevealed,
    bool? finished,
  }) {
    return QuizSessionState(
      index: index ?? this.index,
      correct: correct ?? this.correct,
      incorrect: incorrect ?? this.incorrect,
      answerRevealed: answerRevealed ?? this.answerRevealed,
      startedAt: startedAt,
      finished: finished ?? this.finished,
    );
  }
}

class QuizSessionController extends StateNotifier<QuizSessionState> {
  QuizSessionController() : super(QuizSessionState.initial());

  void revealAnswer() {
    if (!state.answerRevealed) {
      state = state.copyWith(answerRevealed: true);
    }
  }

  void markAnswer({required bool remembered, required int totalCards}) {
    if (!state.answerRevealed || state.finished) return;

    final nextCorrect = state.correct + (remembered ? 1 : 0);
    final nextIncorrect = state.incorrect + (remembered ? 0 : 1);
    final isLast = state.index >= totalCards - 1;

    state = state.copyWith(
      correct: nextCorrect,
      incorrect: nextIncorrect,
      index: isLast ? state.index : state.index + 1,
      answerRevealed: false,
      finished: isLast,
    );
  }
}

final quizSessionProvider = StateNotifierProvider.autoDispose
    .family<QuizSessionController, QuizSessionState, String>((ref, deckId) {
  return QuizSessionController();
});
