import 'flashcard.dart';

/// Immutable multiple-choice question generated from a flashcard.
class McqQuestion {
  const McqQuestion({
    required this.card,
    required this.options,
  }) : assert(options.length == 4);

  final Flashcard card;
  final List<String> options;

  String get correctAnswer => card.answer;

  bool isCorrect(String value) =>
      value.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
}

/// Captures one answered MCQ so incorrect answers can be reviewed later.
class McqAttempt {
  const McqAttempt({
    required this.question,
    required this.selectedAnswer,
  });

  final McqQuestion question;
  final String selectedAnswer;

  bool get isCorrect => question.isCorrect(selectedAnswer);
}
