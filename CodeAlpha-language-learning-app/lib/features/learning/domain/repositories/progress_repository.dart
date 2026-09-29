import '../entities/progress_state.dart';

abstract class ProgressRepository {
  Future<ProgressState> load();
  Future<void> save(ProgressState state);
  Future<void> reset();
}
