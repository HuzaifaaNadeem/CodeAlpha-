import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/flashcard.dart';
import '../../domain/entities/mcq_question.dart';
import '../../domain/services/mcq_quiz_generator.dart';
import 'flashcard_providers.dart';

class McqQuizState {
  const McqQuizState({
    required this.index,
    required this.correct,
    required this.incorrect,
    required this.selectedAnswer,
    required this.startedAt,
    required this.finished,
    required this.attempts,
  });

  factory McqQuizState.initial() => McqQuizState(
        index: 0,
        correct: 0,
        incorrect: 0,
        selectedAnswer: null,
        startedAt: DateTime.now(),
        finished: false,
        attempts: const [],
      );

  final int index;
  final int correct;
  final int incorrect;
  final String? selectedAnswer;
  final DateTime startedAt;
  final bool finished;
  final List<McqAttempt> attempts;

  bool get hasAnswered => selectedAnswer != null;

  McqQuizState copyWith({
    int? index,
    int? correct,
    int? incorrect,
    String? selectedAnswer,
    bool clearSelectedAnswer = false,
    bool? finished,
    List<McqAttempt>? attempts,
  }) {
    return McqQuizState(
      index: index ?? this.index,
      correct: correct ?? this.correct,
      incorrect: incorrect ?? this.incorrect,
      selectedAnswer:
          clearSelectedAnswer ? null : selectedAnswer ?? this.selectedAnswer,
      startedAt: startedAt,
      finished: finished ?? this.finished,
      attempts: attempts ?? this.attempts,
    );
  }
}

class McqQuizController extends StateNotifier<McqQuizState> {
  McqQuizController() : super(McqQuizState.initial());

  void selectAnswer({
    required McqQuestion question,
    required String answer,
  }) {
    if (state.hasAnswered || state.finished) {
      return;
    }

    final correct = question.isCorrect(answer);
    state = state.copyWith(
      selectedAnswer: answer,
      correct: state.correct + (correct ? 1 : 0),
      incorrect: state.incorrect + (correct ? 0 : 1),
      attempts: [
        ...state.attempts,
        McqAttempt(
          question: question,
          selectedAnswer: answer,
        ),
      ],
    );
  }

  void next({required int totalQuestions}) {
    if (!state.hasAnswered || state.finished) {
      return;
    }

    final isLast = state.index >= totalQuestions - 1;
    if (isLast) {
      state = state.copyWith(finished: true);
      return;
    }

    state = state.copyWith(
      index: state.index + 1,
      clearSelectedAnswer: true,
    );
  }
}

final allCardsProvider = FutureProvider<List<Flashcard>>((ref) async {
  return ref.watch(flashcardRepositoryProvider).getAllCards();
});

final mcqQuestionsProvider = FutureProvider.autoDispose
    .family<List<McqQuestion>, String>((ref, deckId) async {
  final deckCards = await ref.watch(cardsProvider(deckId).future);
  final allCards = await ref.watch(allCardsProvider.future);

  return McqQuizGenerator().generate(
    deckCards: deckCards,
    allCards: allCards,
  );
});

final mcqQuizSessionProvider = StateNotifierProvider.autoDispose
    .family<McqQuizController, McqQuizState, String>((ref, deckId) {
  return McqQuizController();
});
