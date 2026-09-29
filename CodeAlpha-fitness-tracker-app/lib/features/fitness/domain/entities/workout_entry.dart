class WorkoutEntry {
  const WorkoutEntry({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.calories,
    required this.startedAt,
    this.intensity = 'Moderate',
    this.distanceKm = 0,
    this.notes = '',
    this.planId,
  });

  final String id;
  final String type;
  final int durationMinutes;
  final int calories;
  final DateTime startedAt;
  final String intensity;
  final double distanceKm;
  final String notes;
  final String? planId;

  WorkoutEntry copyWith({
    String? type,
    int? durationMinutes,
    int? calories,
    String? intensity,
    double? distanceKm,
    String? notes,
    String? planId,
  }) {
    return WorkoutEntry(
      id: id,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      calories: calories ?? this.calories,
      startedAt: startedAt,
      intensity: intensity ?? this.intensity,
      distanceKm: distanceKm ?? this.distanceKm,
      notes: notes ?? this.notes,
      planId: planId ?? this.planId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'durationMinutes': durationMinutes,
        'calories': calories,
        'startedAt': startedAt.toIso8601String(),
        'intensity': intensity,
        'distanceKm': distanceKm,
        'notes': notes,
        'planId': planId,
      };

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutEntry(
      id: json['id'] as String,
      type: json['type'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      calories: (json['calories'] as num).toInt(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      intensity: json['intensity'] as String? ?? 'Moderate',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
      planId: json['planId'] as String?,
    );
  }
}
