class ProgressState {
  const ProgressState({
    required this.completedLessonIds,
    required this.favoriteItemIds,
    required this.totalCorrect,
    required this.totalAnswered,
    required this.currentStreak,
    required this.lastStudyDate,
  });

  factory ProgressState.empty() => const ProgressState(
        completedLessonIds: <String>{},
        favoriteItemIds: <String>{},
        totalCorrect: 0,
        totalAnswered: 0,
        currentStreak: 0,
        lastStudyDate: null,
      );

  final Set<String> completedLessonIds;
  final Set<String> favoriteItemIds;
  final int totalCorrect;
  final int totalAnswered;
  final int currentStreak;
  final String? lastStudyDate;

  double get accuracy => totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;

  ProgressState copyWith({
    Set<String>? completedLessonIds,
    Set<String>? favoriteItemIds,
    int? totalCorrect,
    int? totalAnswered,
    int? currentStreak,
    String? lastStudyDate,
  }) {
    return ProgressState(
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      favoriteItemIds: favoriteItemIds ?? this.favoriteItemIds,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      currentStreak: currentStreak ?? this.currentStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }
}
