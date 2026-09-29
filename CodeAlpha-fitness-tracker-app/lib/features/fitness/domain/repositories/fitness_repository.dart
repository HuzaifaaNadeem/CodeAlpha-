import '../entities/fitness_snapshot.dart';

abstract class FitnessRepository {
  Future<FitnessSnapshot> load();
  Future<void> save(FitnessSnapshot snapshot);
  Future<void> clear();
}
