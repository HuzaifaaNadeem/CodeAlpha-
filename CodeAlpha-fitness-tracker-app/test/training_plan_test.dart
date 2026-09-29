import 'package:codealpha_fitness_tracker_app/features/fitness/domain/entities/training_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all training plans provide a complete seven-day prescription', () {
    expect(trainingPlans.length, greaterThanOrEqualTo(3));
    final ids = <String>{};
    for (final plan in trainingPlans) {
      expect(plan.days.length, 7);
      expect(ids.add(plan.id), isTrue,
          reason: 'Training plan ids must be unique');
      for (final day in plan.days) {
        expect(day.durationMinutes, greaterThan(0));
        expect(day.exercises, isNotEmpty);
      }
    }
  });
}
