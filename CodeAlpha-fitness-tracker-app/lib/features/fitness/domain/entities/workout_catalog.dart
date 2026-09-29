class WorkoutCatalogItem {
  const WorkoutCatalogItem({
    required this.name,
    required this.met,
    required this.category,
    required this.defaultIntensity,
  });

  final String name;
  final double met;
  final String category;
  final String defaultIntensity;
}

const workoutCatalog = [
  WorkoutCatalogItem(
      name: 'Walking', met: 3.5, category: 'Cardio', defaultIntensity: 'Light'),
  WorkoutCatalogItem(
      name: 'Running', met: 9.8, category: 'Cardio', defaultIntensity: 'Hard'),
  WorkoutCatalogItem(
      name: 'Cycling',
      met: 7.5,
      category: 'Cardio',
      defaultIntensity: 'Moderate'),
  WorkoutCatalogItem(
      name: 'Gym',
      met: 6.0,
      category: 'Strength',
      defaultIntensity: 'Moderate'),
  WorkoutCatalogItem(
      name: 'Yoga', met: 3.0, category: 'Mobility', defaultIntensity: 'Light'),
  WorkoutCatalogItem(
      name: 'Swimming',
      met: 8.0,
      category: 'Cardio',
      defaultIntensity: 'Moderate'),
  WorkoutCatalogItem(
      name: 'Cardio',
      met: 7.0,
      category: 'Cardio',
      defaultIntensity: 'Moderate'),
  WorkoutCatalogItem(
      name: 'Strength',
      met: 6.0,
      category: 'Strength',
      defaultIntensity: 'Moderate'),
  WorkoutCatalogItem(
      name: 'HIIT',
      met: 10.0,
      category: 'Conditioning',
      defaultIntensity: 'Hard'),
  WorkoutCatalogItem(
      name: 'Hiking',
      met: 6.5,
      category: 'Outdoor',
      defaultIntensity: 'Moderate'),
  WorkoutCatalogItem(
      name: 'Rowing',
      met: 7.0,
      category: 'Cardio',
      defaultIntensity: 'Moderate'),
  WorkoutCatalogItem(
      name: 'Pilates',
      met: 3.2,
      category: 'Mobility',
      defaultIntensity: 'Light'),
  WorkoutCatalogItem(
      name: 'Other', met: 5.0, category: 'Other', defaultIntensity: 'Moderate'),
];

WorkoutCatalogItem catalogItemFor(String type) {
  for (final item in workoutCatalog) {
    if (item.name == type) {
      return item;
    }
  }
  return workoutCatalog.last;
}

double metForWorkout(String type) => catalogItemFor(type).met;

int estimateCalories({
  required String type,
  required int durationMinutes,
  required double weightKg,
  String intensity = 'Moderate',
}) {
  final baseMet = metForWorkout(type);
  final multiplier = switch (intensity) {
    'Light' => 0.82,
    'Hard' => 1.18,
    _ => 1.0,
  };
  final calories =
      baseMet * multiplier * 3.5 * weightKg / 200 * durationMinutes;
  return calories.round().clamp(1, 8000).toInt();
}

double estimateDistanceKm({
  required String type,
  required int durationMinutes,
  String intensity = 'Moderate',
}) {
  final kmPerHour = switch (type) {
    'Walking' => intensity == 'Hard' ? 6.0 : 4.8,
    'Running' => intensity == 'Light'
        ? 7.5
        : intensity == 'Hard'
            ? 11.5
            : 9.2,
    'Cycling' => intensity == 'Light'
        ? 14.0
        : intensity == 'Hard'
            ? 24.0
            : 18.0,
    'Hiking' => 4.2,
    'Rowing' => 8.0,
    _ => 0.0,
  };
  return kmPerHour * durationMinutes / 60;
}
