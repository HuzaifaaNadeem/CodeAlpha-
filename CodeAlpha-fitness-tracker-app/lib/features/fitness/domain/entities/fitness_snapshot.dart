import 'daily_record.dart';
import 'fitness_profile.dart';

class FitnessSnapshot {
  const FitnessSnapshot({
    required this.profile,
    required this.records,
  });

  final FitnessProfile profile;
  final Map<String, DailyRecord> records;

  FitnessSnapshot copyWith({
    FitnessProfile? profile,
    Map<String, DailyRecord>? records,
  }) {
    return FitnessSnapshot(
      profile: profile ?? this.profile,
      records: records ?? this.records,
    );
  }
}
