class FitnessProfile {
  const FitnessProfile({
    required this.name,
    required this.stepGoal,
    required this.activeMinuteGoal,
    required this.calorieGoal,
    required this.waterGoalMl,
    required this.weightKg,
    this.heightCm = 175,
    this.age = 28,
    this.targetWeightKg = 68,
    this.sleepGoalMinutes = 480,
    this.calorieIntakeGoal = 2200,
    this.proteinGoalGrams = 130,
    this.weeklyWorkoutGoal = 4,
    this.activePlanId = 'balanced-foundation',
  });

  final String name;
  final int stepGoal;
  final int activeMinuteGoal;
  final int calorieGoal;
  final int waterGoalMl;
  final double weightKg;
  final double heightCm;
  final int age;
  final double targetWeightKg;
  final int sleepGoalMinutes;
  final int calorieIntakeGoal;
  final int proteinGoalGrams;
  final int weeklyWorkoutGoal;
  final String activePlanId;

  FitnessProfile copyWith({
    String? name,
    int? stepGoal,
    int? activeMinuteGoal,
    int? calorieGoal,
    int? waterGoalMl,
    double? weightKg,
    double? heightCm,
    int? age,
    double? targetWeightKg,
    int? sleepGoalMinutes,
    int? calorieIntakeGoal,
    int? proteinGoalGrams,
    int? weeklyWorkoutGoal,
    String? activePlanId,
  }) {
    return FitnessProfile(
      name: name ?? this.name,
      stepGoal: stepGoal ?? this.stepGoal,
      activeMinuteGoal: activeMinuteGoal ?? this.activeMinuteGoal,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      waterGoalMl: waterGoalMl ?? this.waterGoalMl,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      sleepGoalMinutes: sleepGoalMinutes ?? this.sleepGoalMinutes,
      calorieIntakeGoal: calorieIntakeGoal ?? this.calorieIntakeGoal,
      proteinGoalGrams: proteinGoalGrams ?? this.proteinGoalGrams,
      weeklyWorkoutGoal: weeklyWorkoutGoal ?? this.weeklyWorkoutGoal,
      activePlanId: activePlanId ?? this.activePlanId,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'stepGoal': stepGoal,
        'activeMinuteGoal': activeMinuteGoal,
        'calorieGoal': calorieGoal,
        'waterGoalMl': waterGoalMl,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'age': age,
        'targetWeightKg': targetWeightKg,
        'sleepGoalMinutes': sleepGoalMinutes,
        'calorieIntakeGoal': calorieIntakeGoal,
        'proteinGoalGrams': proteinGoalGrams,
        'weeklyWorkoutGoal': weeklyWorkoutGoal,
        'activePlanId': activePlanId,
      };

  factory FitnessProfile.fromJson(Map<String, dynamic> json) {
    return FitnessProfile(
      name: json['name'] as String? ?? 'Athlete',
      stepGoal: (json['stepGoal'] as num?)?.toInt() ?? 10000,
      activeMinuteGoal: (json['activeMinuteGoal'] as num?)?.toInt() ?? 45,
      calorieGoal: (json['calorieGoal'] as num?)?.toInt() ?? 500,
      waterGoalMl: (json['waterGoalMl'] as num?)?.toInt() ?? 2500,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 70.0,
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 175.0,
      age: (json['age'] as num?)?.toInt() ?? 28,
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 68.0,
      sleepGoalMinutes: (json['sleepGoalMinutes'] as num?)?.toInt() ?? 480,
      calorieIntakeGoal: (json['calorieIntakeGoal'] as num?)?.toInt() ?? 2200,
      proteinGoalGrams: (json['proteinGoalGrams'] as num?)?.toInt() ?? 130,
      weeklyWorkoutGoal: (json['weeklyWorkoutGoal'] as num?)?.toInt() ?? 4,
      activePlanId: json['activePlanId'] as String? ?? 'balanced-foundation',
    );
  }
}
