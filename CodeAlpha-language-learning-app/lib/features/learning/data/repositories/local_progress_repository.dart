import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/progress_state.dart';
import '../../domain/repositories/progress_repository.dart';

class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository(this._preferences);

  final SharedPreferences _preferences;

  static const _completedKey = 'completed_lessons';
  static const _favoritesKey = 'favorite_items';
  static const _correctKey = 'total_correct';
  static const _answeredKey = 'total_answered';
  static const _streakKey = 'current_streak';
  static const _lastStudyKey = 'last_study_date';

  @override
  Future<ProgressState> load() async {
    return ProgressState(
      completedLessonIds:
          (_preferences.getStringList(_completedKey) ?? <String>[]).toSet(),
      favoriteItemIds:
          (_preferences.getStringList(_favoritesKey) ?? <String>[]).toSet(),
      totalCorrect: _preferences.getInt(_correctKey) ?? 0,
      totalAnswered: _preferences.getInt(_answeredKey) ?? 0,
      currentStreak: _preferences.getInt(_streakKey) ?? 0,
      lastStudyDate: _preferences.getString(_lastStudyKey),
    );
  }

  @override
  Future<void> save(ProgressState state) async {
    await Future.wait([
      _preferences.setStringList(
          _completedKey, state.completedLessonIds.toList()),
      _preferences.setStringList(_favoritesKey, state.favoriteItemIds.toList()),
      _preferences.setInt(_correctKey, state.totalCorrect),
      _preferences.setInt(_answeredKey, state.totalAnswered),
      _preferences.setInt(_streakKey, state.currentStreak),
      if (state.lastStudyDate != null)
        _preferences.setString(_lastStudyKey, state.lastStudyDate!),
    ]);
  }

  @override
  Future<void> reset() async {
    await Future.wait([
      _preferences.remove(_completedKey),
      _preferences.remove(_favoritesKey),
      _preferences.remove(_correctKey),
      _preferences.remove(_answeredKey),
      _preferences.remove(_streakKey),
      _preferences.remove(_lastStudyKey),
    ]);
  }
}
