import 'package:codealpha_fitness_tracker_app/features/fitness/domain/entities/workout_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('running burns more calories than walking for same profile and duration',
      () {
    final walking =
        estimateCalories(type: 'Walking', durationMinutes: 30, weightKg: 70);
    final running =
        estimateCalories(type: 'Running', durationMinutes: 30, weightKg: 70);

    expect(running, greaterThan(walking));
    expect(workoutCatalog.length, 13);
  });

  test('hard intensity burns more than light intensity', () {
    final light = estimateCalories(
        type: 'Cycling', durationMinutes: 30, weightKg: 70, intensity: 'Light');
    final hard = estimateCalories(
        type: 'Cycling', durationMinutes: 30, weightKg: 70, intensity: 'Hard');
    expect(hard, greaterThan(light));
  });
}
