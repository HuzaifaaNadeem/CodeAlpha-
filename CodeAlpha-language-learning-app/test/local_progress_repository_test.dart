import 'package:codealpha_language_learning_app/features/learning/data/repositories/local_progress_repository.dart';
import 'package:codealpha_language_learning_app/features/learning/domain/entities/progress_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('progress repository saves and restores learning state', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalProgressRepository(preferences);

    const state = ProgressState(
      completedLessonIds: {'greetings'},
      favoriteItemIds: {'hello'},
      totalCorrect: 7,
      totalAnswered: 10,
      currentStreak: 3,
      lastStudyDate: '2026-09-10',
    );

    await repository.save(state);
    final restored = await repository.load();

    expect(restored.completedLessonIds, contains('greetings'));
    expect(restored.favoriteItemIds, contains('hello'));
    expect(restored.totalCorrect, 7);
    expect(restored.totalAnswered, 10);
    expect(restored.currentStreak, 3);
  });
}
