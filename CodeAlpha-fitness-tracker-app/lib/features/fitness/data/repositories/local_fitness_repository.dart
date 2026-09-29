import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/daily_record.dart';
import '../../domain/entities/fitness_profile.dart';
import '../../domain/entities/fitness_snapshot.dart';
import '../../domain/entities/workout_entry.dart';
import '../../domain/repositories/fitness_repository.dart';

class LocalFitnessRepository implements FitnessRepository {
  static const _storageKey = 'pulsefit_snapshot_v2';
  static const _legacyStorageKey = 'pulsefit_snapshot_v1';

  @override
  Future<FitnessSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw =
        prefs.getString(_storageKey) ?? prefs.getString(_legacyStorageKey);

    if (raw == null || raw.isEmpty) {
      final seed = _seedSnapshot();
      await save(seed);
      return seed;
    }

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final profile = FitnessProfile.fromJson(
        Map<String, dynamic>.from(data['profile'] as Map),
      );
      final recordsList = (data['records'] as List<dynamic>?) ?? const [];
      final records = <String, DailyRecord>{};

      for (final item in recordsList) {
        final record = DailyRecord.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
        records[_key(record.date)] = record;
      }

      final snapshot = FitnessSnapshot(profile: profile, records: records);
      if (prefs.getString(_storageKey) == null) {
        await save(snapshot);
      }
      return snapshot;
    } catch (_) {
      final seed = _seedSnapshot();
      await save(seed);
      return seed;
    }
  }

  @override
  Future<void> save(FitnessSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'profile': snapshot.profile.toJson(),
      'records': snapshot.records.values.map((e) => e.toJson()).toList(),
    };
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.remove(_legacyStorageKey);
  }

  static FitnessSnapshot _seedSnapshot() {
    final now = DateTime.now();
    final records = <String, DailyRecord>{};
    const steps = [
      7120,
      9450,
      10840,
      6340,
      11890,
      8240,
      10210,
      7580,
      9230,
      11120,
      6880,
      12540,
      9870,
      7460,
    ];
    const water = [
      1800,
      2300,
      2600,
      1650,
      2800,
      2200,
      2500,
      1900,
      2400,
      2650,
      2000,
      2900,
      2500,
      1750,
    ];
    const sleep = [
      430,
      468,
      492,
      410,
      500,
      455,
      480,
      440,
      475,
      505,
      420,
      495,
      470,
      452,
    ];
    const hr = [62, 60, 59, 64, 58, 61, 60, 63, 60, 58, 64, 57, 59, 61];
    const caloriesIn = [
      2150,
      2280,
      2180,
      2410,
      2210,
      2350,
      2260,
      2190,
      2240,
      2160,
      2390,
      2230,
      2310,
      2200,
    ];
    const protein = [
      118,
      132,
      141,
      110,
      146,
      126,
      135,
      121,
      137,
      144,
      116,
      149,
      139,
      128,
    ];

    for (var i = 13; i >= 0; i--) {
      final date =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final index = 13 - i;
      final workouts = <WorkoutEntry>[];

      if (index % 3 == 1) {
        workouts.add(
          WorkoutEntry(
            id: 'seed-$index-a',
            type: index.isEven ? 'Strength' : 'Gym',
            durationMinutes: 42 + index % 8,
            calories: 300 + index * 5,
            startedAt: DateTime(date.year, date.month, date.day, 18, 10),
            intensity: 'Moderate',
            notes: 'Progressive full-body session.',
          ),
        );
      }
      if (index % 4 == 2) {
        workouts.add(
          WorkoutEntry(
            id: 'seed-$index-b',
            type: index.isEven ? 'Running' : 'Cycling',
            durationMinutes: 30 + index % 12,
            calories: 330 + index * 7,
            startedAt: DateTime(date.year, date.month, date.day, 7, 20),
            intensity: index % 8 == 2 ? 'Hard' : 'Moderate',
            distanceKm: index.isEven ? 5.2 + index / 20 : 12.0 + index / 3,
            notes: 'Steady aerobic work.',
          ),
        );
      }
      if (index == 13) {
        workouts.add(
          WorkoutEntry(
            id: 'seed-today',
            type: 'Walking',
            durationMinutes: 24,
            calories: 126,
            startedAt: DateTime(date.year, date.month, date.day, 8, 5),
            intensity: 'Light',
            distanceKm: 1.9,
          ),
        );
      }

      final record = DailyRecord(
        date: date,
        steps: steps[index],
        waterMl: water[index],
        workouts: workouts,
        sleepMinutes: sleep[index],
        restingHeartRate: hr[index],
        caloriesConsumed: caloriesIn[index],
        proteinGrams: protein[index],
        carbsGrams: 210 + (index % 5) * 16,
        fatGrams: 62 + (index % 4) * 6,
        mindfulMinutes: 5 + (index % 4) * 5,
        floorsClimbed: 4 + (index % 7),
        moodScore: 3 + (index % 3),
        weightKg: 70.8 - index * 0.06,
      );
      records[_key(date)] = record;
    }

    return FitnessSnapshot(
      profile: const FitnessProfile(
        name: 'Athlete',
        stepGoal: 10000,
        activeMinuteGoal: 45,
        calorieGoal: 500,
        waterGoalMl: 2500,
        weightKg: 70,
        heightCm: 175,
        age: 28,
        targetWeightKg: 68,
        sleepGoalMinutes: 480,
        calorieIntakeGoal: 2200,
        proteinGoalGrams: 130,
        weeklyWorkoutGoal: 4,
        activePlanId: 'balanced-foundation',
      ),
      records: records,
    );
  }

  static String _key(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
