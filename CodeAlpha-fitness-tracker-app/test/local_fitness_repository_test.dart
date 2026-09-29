import 'package:codealpha_fitness_tracker_app/features/fitness/data/repositories/local_fitness_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('repository seeds rich two-week performance history', () async {
    final repository = LocalFitnessRepository();
    final snapshot = await repository.load();

    expect(snapshot.profile.stepGoal, 10000);
    expect(snapshot.profile.sleepGoalMinutes, 480);
    expect(snapshot.records.length, 14);
    expect(snapshot.records.values.any((record) => record.workouts.isNotEmpty),
        isTrue);
    expect(snapshot.records.values.any((record) => record.sleepMinutes > 0),
        isTrue);
    expect(snapshot.records.values.any((record) => record.proteinGrams > 0),
        isTrue);
  });
}
