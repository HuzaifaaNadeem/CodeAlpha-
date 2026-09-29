import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_key.dart';
import '../../data/sources/starter_course.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/learning_item.dart';
import '../../domain/entities/progress_state.dart';
import '../../domain/repositories/progress_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  throw UnimplementedError('Override progressRepositoryProvider in main().');
});

final lessonsProvider = Provider<List<Lesson>>((ref) => StarterCourse.lessons);
final allItemsProvider =
    Provider<List<LearningItem>>((ref) => StarterCourse.allItems);

final progressControllerProvider =
    StateNotifierProvider<ProgressController, AsyncValue<ProgressState>>((ref) {
  return ProgressController(ref.read(progressRepositoryProvider));
});

class ProgressController extends StateNotifier<AsyncValue<ProgressState>> {
  ProgressController(this._repository) : super(const AsyncLoading()) {
    _load();
  }

  final ProgressRepository _repository;

  Future<void> _load() async {
    state = await AsyncValue.guard(_repository.load);
  }

  Future<void> _update(
      ProgressState Function(ProgressState current) change) async {
    final current = state.value;
    if (current == null) {
      return;
    }

    final updated = _withStudyDay(change(current));
    state = AsyncData(updated);
    await _repository.save(updated);
  }

  ProgressState _withStudyDay(ProgressState current) {
    final today = dateKey(DateTime.now());
    if (current.lastStudyDate == today) {
      return current;
    }

    var streak = 1;
    if (current.lastStudyDate != null) {
      final previous = DateTime.tryParse(current.lastStudyDate!);
      if (previous != null) {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        if (dateKey(previous) == dateKey(yesterday)) {
          streak = current.currentStreak + 1;
        }
      }
    }

    return current.copyWith(currentStreak: streak, lastStudyDate: today);
  }

  Future<void> completeLesson(String lessonId) async {
    await _update((current) {
      final next = {...current.completedLessonIds, lessonId};
      return current.copyWith(completedLessonIds: next);
    });
  }

  Future<void> toggleFavorite(String itemId) async {
    await _update((current) {
      final next = {...current.favoriteItemIds};
      if (!next.add(itemId)) {
        next.remove(itemId);
      }
      return current.copyWith(favoriteItemIds: next);
    });
  }

  Future<void> recordAnswer({required bool correct}) async {
    await _update((current) {
      return current.copyWith(
        totalCorrect: current.totalCorrect + (correct ? 1 : 0),
        totalAnswered: current.totalAnswered + 1,
      );
    });
  }

  Future<void> touchStudyDay() async {
    await _update((current) => current);
  }

  Future<void> reset() async {
    await _repository.reset();
    state = AsyncData(ProgressState.empty());
  }
}
