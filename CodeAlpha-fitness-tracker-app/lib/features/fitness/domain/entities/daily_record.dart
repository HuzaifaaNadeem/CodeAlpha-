import 'workout_entry.dart';

class DailyRecord {
  const DailyRecord({
    required this.date,
    required this.steps,
    required this.waterMl,
    required this.workouts,
    this.sleepMinutes = 0,
    this.restingHeartRate = 0,
    this.caloriesConsumed = 0,
    this.proteinGrams = 0,
    this.carbsGrams = 0,
    this.fatGrams = 0,
    this.mindfulMinutes = 0,
    this.floorsClimbed = 0,
    this.moodScore = 0,
    this.weightKg = 0,
  });

  final DateTime date;
  final int steps;
  final int waterMl;
  final List<WorkoutEntry> workouts;
  final int sleepMinutes;
  final int restingHeartRate;
  final int caloriesConsumed;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int mindfulMinutes;
  final int floorsClimbed;
  final int moodScore;
  final double weightKg;

  int get activeMinutes =>
      workouts.fold(0, (sum, item) => sum + item.durationMinutes);
  int get workoutCalories =>
      workouts.fold(0, (sum, item) => sum + item.calories);
  double get distanceKm =>
      steps * 0.00078 +
      workouts.fold<double>(0, (sum, item) => sum + item.distanceKm);
  int get sleepHours => sleepMinutes ~/ 60;
  int get sleepRemainderMinutes => sleepMinutes % 60;

  DailyRecord copyWith({
    int? steps,
    int? waterMl,
    List<WorkoutEntry>? workouts,
    int? sleepMinutes,
    int? restingHeartRate,
    int? caloriesConsumed,
    int? proteinGrams,
    int? carbsGrams,
    int? fatGrams,
    int? mindfulMinutes,
    int? floorsClimbed,
    int? moodScore,
    double? weightKg,
  }) {
    return DailyRecord(
      date: date,
      steps: steps ?? this.steps,
      waterMl: waterMl ?? this.waterMl,
      workouts: workouts ?? this.workouts,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      mindfulMinutes: mindfulMinutes ?? this.mindfulMinutes,
      floorsClimbed: floorsClimbed ?? this.floorsClimbed,
      moodScore: moodScore ?? this.moodScore,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'steps': steps,
        'waterMl': waterMl,
        'workouts': workouts.map((e) => e.toJson()).toList(),
        'sleepMinutes': sleepMinutes,
        'restingHeartRate': restingHeartRate,
        'caloriesConsumed': caloriesConsumed,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'mindfulMinutes': mindfulMinutes,
        'floorsClimbed': floorsClimbed,
        'moodScore': moodScore,
        'weightKg': weightKg,
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      date: DateTime.parse(json['date'] as String),
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      waterMl: (json['waterMl'] as num?)?.toInt() ?? 0,
      workouts: ((json['workouts'] as List<dynamic>?) ?? const [])
          .map(
              (e) => WorkoutEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      sleepMinutes: (json['sleepMinutes'] as num?)?.toInt() ?? 0,
      restingHeartRate: (json['restingHeartRate'] as num?)?.toInt() ?? 0,
      caloriesConsumed: (json['caloriesConsumed'] as num?)?.toInt() ?? 0,
      proteinGrams: (json['proteinGrams'] as num?)?.toInt() ?? 0,
      carbsGrams: (json['carbsGrams'] as num?)?.toInt() ?? 0,
      fatGrams: (json['fatGrams'] as num?)?.toInt() ?? 0,
      mindfulMinutes: (json['mindfulMinutes'] as num?)?.toInt() ?? 0,
      floorsClimbed: (json['floorsClimbed'] as num?)?.toInt() ?? 0,
      moodScore: (json['moodScore'] as num?)?.toInt() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
    );
  }
}
