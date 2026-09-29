class QuizStat {
  const QuizStat({
    required this.id,
    required this.deckId,
    required this.correct,
    required this.incorrect,
    required this.durationSeconds,
    required this.completedAt,
  });

  final String id;
  final String deckId;
  final int correct;
  final int incorrect;
  final int durationSeconds;
  final DateTime completedAt;

  int get total => correct + incorrect;
  double get accuracy => total == 0 ? 0 : correct / total;
}
