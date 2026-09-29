import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/local_fitness_repository.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/daily_record.dart';
import '../../domain/entities/fitness_profile.dart';
import '../../domain/entities/fitness_snapshot.dart';
import '../../domain/entities/training_plan.dart';
import '../../domain/entities/workout_entry.dart';
import '../../domain/repositories/fitness_repository.dart';

class FitnessState {
  const FitnessState({
    required this.isLoading,
    required this.snapshot,
  });

  final bool isLoading;
  final FitnessSnapshot? snapshot;

  FitnessProfile? get profile => snapshot?.profile;

  FitnessState copyWith({
    bool? isLoading,
    FitnessSnapshot? snapshot,
  }) {
    return FitnessState(
      isLoading: isLoading ?? this.isLoading,
      snapshot: snapshot ?? this.snapshot,
    );
  }
}

final fitnessRepositoryProvider = Provider<FitnessRepository>((ref) {
  return LocalFitnessRepository();
});

final fitnessControllerProvider =
    StateNotifierProvider<FitnessController, FitnessState>((ref) {
  final controller = FitnessController(ref.watch(fitnessRepositoryProvider));
  controller.load();
  return controller;
});

class FitnessController extends StateNotifier<FitnessState> {
  FitnessController(this._repository)
      : super(const FitnessState(isLoading: true, snapshot: null));

  final FitnessRepository _repository;

  Future<void> load() async {
    final snapshot = await _repository.load();
    state = FitnessState(isLoading: false, snapshot: snapshot);
  }

  DailyRecord recordFor(DateTime date) {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return DailyRecord(
        date: _dateOnly(date),
        steps: 0,
        waterMl: 0,
        workouts: const [],
      );
    }

    return snapshot.records[_key(date)] ??
        DailyRecord(
          date: _dateOnly(date),
          steps: 0,
          waterMl: 0,
          workouts: const [],
          weightKg: snapshot.profile.weightKg,
        );
  }

  List<DailyRecord> recentRecords({int days = 7}) {
    final now = DateTime.now();
    return List.generate(days, (index) {
      final date = _dateOnly(now).subtract(Duration(days: days - 1 - index));
      return recordFor(date);
    });
  }

  List<WorkoutEntry> allWorkouts() {
    final workouts = <WorkoutEntry>[];
    for (final record
        in state.snapshot?.records.values ?? const <DailyRecord>[]) {
      workouts.addAll(record.workouts);
    }
    workouts.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return workouts;
  }

  Future<void> addWorkout({
    required String type,
    required int durationMinutes,
    required int calories,
    DateTime? startedAt,
    String intensity = 'Moderate',
    double distanceKm = 0,
    String notes = '',
    String? planId,
  }) async {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }

    final start = startedAt ?? DateTime.now();
    final date = _dateOnly(start);
    final current = recordFor(date);
    final entry = WorkoutEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      durationMinutes: durationMinutes,
      calories: calories,
      startedAt: start,
      intensity: intensity,
      distanceKm: distanceKm,
      notes: notes,
      planId: planId,
    );

    final updated = current.copyWith(workouts: [...current.workouts, entry]);
    await _replaceRecord(snapshot, updated);
  }

  Future<void> updateWorkout(
    WorkoutEntry original, {
    required String type,
    required int durationMinutes,
    required int calories,
    String? intensity,
    double? distanceKm,
    String? notes,
  }) async {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }

    final key = _key(original.startedAt);
    final record = snapshot.records[key];
    if (record == null) {
      return;
    }

    final updatedWorkout = original.copyWith(
      type: type,
      durationMinutes: durationMinutes,
      calories: calories,
      intensity: intensity,
      distanceKm: distanceKm,
      notes: notes,
    );
    final workouts = record.workouts
        .map((item) => item.id == original.id ? updatedWorkout : item)
        .toList();
    await _replaceRecord(snapshot, record.copyWith(workouts: workouts));
  }

  Future<void> deleteWorkout(WorkoutEntry workout) async {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }

    final key = _key(workout.startedAt);
    final record = snapshot.records[key];
    if (record == null) {
      return;
    }

    final workouts =
        record.workouts.where((item) => item.id != workout.id).toList();
    await _replaceRecord(snapshot, record.copyWith(workouts: workouts));
  }

  Future<void> addSteps(int delta) async {
    final snapshot = state.snapshot;
    if (snapshot == null || delta == 0) {
      return;
    }
    final current = recordFor(DateTime.now());
    final updated = current.copyWith(
      steps: (current.steps + delta).clamp(0, 150000).toInt(),
    );
    await _replaceRecord(snapshot, updated);
  }

  Future<void> setTodaySteps(int steps) async {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }
    final current = recordFor(DateTime.now());
    await _replaceRecord(
      snapshot,
      current.copyWith(steps: steps.clamp(0, 150000).toInt()),
    );
  }

  Future<void> addWater(int deltaMl) async {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }
    final current = recordFor(DateTime.now());
    final updated = current.copyWith(
      waterMl: (current.waterMl + deltaMl).clamp(0, 12000).toInt(),
    );
    await _replaceRecord(snapshot, updated);
  }

  Future<void> logNutrition({
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }
    final current = recordFor(DateTime.now());
    await _replaceRecord(
      snapshot,
      current.copyWith(
        caloriesConsumed:
            (current.caloriesConsumed + calories).clamp(0, 10000).toInt(),
        proteinGrams: (current.proteinGrams + protein).clamp(0, 1000).toInt(),
        carbsGrams: (current.carbsGrams + carbs).clamp(0, 1500).toInt(),
        fatGrams: (current.fatGrams + fat).clamp(0, 600).toInt(),
      ),
    );
  }

  Future<void> logRecovery({
    required int sleepMinutes,
    required int restingHeartRate,
    required int moodScore,
    required int mindfulMinutes,
    double? weightKg,
  }) async {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }
    final current = recordFor(DateTime.now());
    await _replaceRecord(
      snapshot,
      current.copyWith(
        sleepMinutes: sleepMinutes.clamp(0, 900).toInt(),
        restingHeartRate: restingHeartRate.clamp(0, 220).toInt(),
        moodScore: moodScore.clamp(0, 5).toInt(),
        mindfulMinutes: mindfulMinutes.clamp(0, 240).toInt(),
        weightKg: weightKg ?? current.weightKg,
      ),
    );
    if (weightKg != null && weightKg > 0) {
      await updateProfile(snapshot.profile.copyWith(weightKg: weightKg));
    }
  }

  Future<void> addFloors(int delta) async {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }
    final current = recordFor(DateTime.now());
    await _replaceRecord(
      snapshot,
      current.copyWith(
        floorsClimbed: (current.floorsClimbed + delta).clamp(0, 500).toInt(),
      ),
    );
  }

  Future<void> updateProfile(FitnessProfile profile) async {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }
    final updated = snapshot.copyWith(profile: profile);
    state = FitnessState(isLoading: false, snapshot: updated);
    await _repository.save(updated);
  }

  Future<void> selectTrainingPlan(String planId) async {
    final profile = state.profile;
    if (profile == null) {
      return;
    }
    await updateProfile(profile.copyWith(activePlanId: planId));
  }

  TrainingPlan get activePlan =>
      planById(state.profile?.activePlanId ?? trainingPlans.first.id);

  int wellnessScore(DailyRecord record) {
    final profile = state.profile;
    if (profile == null) {
      return 0;
    }
    final sleep = record.sleepMinutes <= 0
        ? 0.55
        : (record.sleepMinutes / profile.sleepGoalMinutes).clamp(0.0, 1.0);
    final hydration = (record.waterMl / profile.waterGoalMl).clamp(0.0, 1.0);
    final movement = (record.steps / profile.stepGoal).clamp(0.0, 1.0);
    final mood = record.moodScore <= 0 ? 0.6 : record.moodScore / 5;
    final score = sleep * 35 + hydration * 20 + movement * 25 + mood * 20;
    return score.round().clamp(0, 100).toInt();
  }

  int currentStepStreak() {
    final profile = state.profile;
    if (profile == null) {
      return 0;
    }
    var streak = 0;
    for (var i = 0; i < 365; i++) {
      final record = recordFor(DateTime.now().subtract(Duration(days: i)));
      if (record.steps >= profile.stepGoal) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  List<Achievement> achievements() {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return const [];
    }
    final records = snapshot.records.values.toList();
    final workouts = allWorkouts();
    final totalSteps = records.fold<int>(0, (sum, item) => sum + item.steps);
    final totalMinutes =
        workouts.fold<int>(0, (sum, item) => sum + item.durationMinutes);
    final last7 = recentRecords();
    final weekSteps = last7.fold<int>(0, (sum, item) => sum + item.steps);
    final weekWorkouts =
        last7.fold<int>(0, (sum, item) => sum + item.workouts.length);
    final bestSteps = records.fold<int>(
      0,
      (best, item) => item.steps > best ? item.steps : best,
    );
    final hydrationHit = records.any(
      (item) => item.waterMl >= snapshot.profile.waterGoalMl,
    );
    final earlyWorkout = workouts.any((item) => item.startedAt.hour < 8);

    double progress(int value, int target) =>
        (value / target).clamp(0.0, 1.0).toDouble();

    return [
      Achievement(
        id: 'first-move',
        title: 'First Move',
        description: 'Complete your first workout.',
        iconKey: 'bolt',
        unlocked: workouts.isNotEmpty,
        progress: progress(workouts.length, 1),
      ),
      Achievement(
        id: '10k-club',
        title: '10K Club',
        description: 'Hit 10,000 steps in a single day.',
        iconKey: 'steps',
        unlocked: bestSteps >= 10000,
        progress: progress(bestSteps, 10000),
      ),
      Achievement(
        id: 'week-warrior',
        title: 'Week Warrior',
        description: 'Complete 4 workouts in 7 days.',
        iconKey: 'shield',
        unlocked: weekWorkouts >= 4,
        progress: progress(weekWorkouts, 4),
      ),
      Achievement(
        id: '50k-week',
        title: '50K Week',
        description: 'Walk 50,000 steps across 7 days.',
        iconKey: 'route',
        unlocked: weekSteps >= 50000,
        progress: progress(weekSteps, 50000),
      ),
      Achievement(
        id: 'hydrated',
        title: 'Hydration Hero',
        description: 'Reach your daily water goal.',
        iconKey: 'water',
        unlocked: hydrationHit,
        progress: hydrationHit ? 1 : 0.75,
      ),
      Achievement(
        id: '100k',
        title: 'Century Walker',
        description: 'Accumulate 100,000 lifetime steps.',
        iconKey: 'medal',
        unlocked: totalSteps >= 100000,
        progress: progress(totalSteps, 100000),
      ),
      Achievement(
        id: '500-min',
        title: 'Time Under Tension',
        description: 'Accumulate 500 active workout minutes.',
        iconKey: 'timer',
        unlocked: totalMinutes >= 500,
        progress: progress(totalMinutes, 500),
      ),
      Achievement(
        id: 'early-bird',
        title: 'Early Bird',
        description: 'Complete a workout before 8 AM.',
        iconKey: 'sun',
        unlocked: earlyWorkout,
        progress: earlyWorkout ? 1 : 0,
      ),
    ];
  }

  String exportJson() {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return '{}';
    }
    return const JsonEncoder.withIndent('  ').convert({
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': snapshot.profile.toJson(),
      'records': snapshot.records.values.map((e) => e.toJson()).toList(),
    });
  }

  String exportCsv() {
    final rows = <String>[
      'date,steps,distance_km,water_ml,sleep_minutes,resting_hr,calories_consumed,protein_g,carbs_g,fat_g,active_minutes,workout_calories,workouts',
    ];
    final records = state.snapshot?.records.values.toList() ?? <DailyRecord>[];
    records.sort((a, b) => a.date.compareTo(b.date));
    for (final record in records) {
      rows.add([
        _key(record.date),
        record.steps,
        record.distanceKm.toStringAsFixed(2),
        record.waterMl,
        record.sleepMinutes,
        record.restingHeartRate,
        record.caloriesConsumed,
        record.proteinGrams,
        record.carbsGrams,
        record.fatGrams,
        record.activeMinutes,
        record.workoutCalories,
        record.workouts.length,
      ].join(','));
    }
    return rows.join('\n');
  }

  Future<void> reset() async {
    state = const FitnessState(isLoading: true, snapshot: null);
    await _repository.clear();
    await load();
  }

  Future<void> _replaceRecord(
    FitnessSnapshot snapshot,
    DailyRecord record,
  ) async {
    final records = Map<String, DailyRecord>.from(snapshot.records)
      ..[_key(record.date)] = record;
    final updated = snapshot.copyWith(records: records);
    state = FitnessState(isLoading: false, snapshot: updated);
    await _repository.save(updated);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String _key(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
