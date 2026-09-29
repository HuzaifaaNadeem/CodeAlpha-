class TrainingDay {
  const TrainingDay({
    required this.dayIndex,
    required this.title,
    required this.workoutType,
    required this.durationMinutes,
    required this.focus,
    required this.exercises,
  });

  final int dayIndex;
  final String title;
  final String workoutType;
  final int durationMinutes;
  final String focus;
  final List<String> exercises;
}

class TrainingPlan {
  const TrainingPlan({
    required this.id,
    required this.title,
    required this.tagline,
    required this.level,
    required this.durationWeeks,
    required this.accentKey,
    required this.days,
  });

  final String id;
  final String title;
  final String tagline;
  final String level;
  final int durationWeeks;
  final String accentKey;
  final List<TrainingDay> days;

  TrainingDay dayFor(DateTime date) {
    final index = (date.weekday - 1) % days.length;
    return days[index];
  }
}

const trainingPlans = [
  TrainingPlan(
    id: 'balanced-foundation',
    title: 'Balanced Foundation',
    tagline: 'Build strength, cardio, mobility, and consistency.',
    level: 'All levels',
    durationWeeks: 4,
    accentKey: 'green',
    days: [
      TrainingDay(
          dayIndex: 1,
          title: 'Full-body strength',
          workoutType: 'Strength',
          durationMinutes: 40,
          focus: 'Strength',
          exercises: [
            'Goblet squat · 3×10',
            'Push-up · 3×10',
            'Romanian deadlift · 3×10',
            'One-arm row · 3×12',
            'Dead bug · 3×10/side'
          ]),
      TrainingDay(
          dayIndex: 2,
          title: 'Zone 2 walk',
          workoutType: 'Walking',
          durationMinutes: 35,
          focus: 'Aerobic base',
          exercises: [
            '5 min easy warm-up',
            '25 min brisk sustainable pace',
            '5 min relaxed cool-down'
          ]),
      TrainingDay(
          dayIndex: 3,
          title: 'Mobility reset',
          workoutType: 'Yoga',
          durationMinutes: 25,
          focus: 'Mobility',
          exercises: [
            '90/90 hip flow',
            'World’s greatest stretch',
            'Thoracic rotations',
            'Hamstring flow',
            'Box breathing'
          ]),
      TrainingDay(
          dayIndex: 4,
          title: 'Tempo cardio',
          workoutType: 'Cardio',
          durationMinutes: 30,
          focus: 'Conditioning',
          exercises: [
            '5 min warm-up',
            '4×4 min strong effort',
            '2 min easy between rounds',
            '5 min cool-down'
          ]),
      TrainingDay(
          dayIndex: 5,
          title: 'Strength + core',
          workoutType: 'Gym',
          durationMinutes: 45,
          focus: 'Strength',
          exercises: [
            'Split squat · 3×10',
            'Overhead press · 3×8',
            'Lat pulldown · 3×10',
            'Hip thrust · 3×12',
            'Side plank · 3×30 sec'
          ]),
      TrainingDay(
          dayIndex: 6,
          title: 'Long easy session',
          workoutType: 'Cycling',
          durationMinutes: 50,
          focus: 'Endurance',
          exercises: [
            'Keep effort conversational',
            'Smooth cadence',
            'Finish feeling capable of more'
          ]),
      TrainingDay(
          dayIndex: 7,
          title: 'Recovery day',
          workoutType: 'Yoga',
          durationMinutes: 20,
          focus: 'Recovery',
          exercises: [
            'Gentle mobility',
            '10 min easy walk',
            'Breathing reset'
          ]),
    ],
  ),
  TrainingPlan(
    id: '5k-momentum',
    title: '5K Momentum',
    tagline: 'A progressive run-walk plan for stronger endurance.',
    level: 'Beginner',
    durationWeeks: 6,
    accentKey: 'blue',
    days: [
      TrainingDay(
          dayIndex: 1,
          title: 'Run-walk intervals',
          workoutType: 'Running',
          durationMinutes: 30,
          focus: 'Intervals',
          exercises: ['5 min walk', '6×3 min run / 90 sec walk', '5 min walk']),
      TrainingDay(
          dayIndex: 2,
          title: 'Mobility + core',
          workoutType: 'Yoga',
          durationMinutes: 25,
          focus: 'Durability',
          exercises: [
            'Calf mobility',
            'Hip flexor stretch',
            'Glute bridge · 3×12',
            'Dead bug · 3×10'
          ]),
      TrainingDay(
          dayIndex: 3,
          title: 'Easy run',
          workoutType: 'Running',
          durationMinutes: 28,
          focus: 'Aerobic base',
          exercises: [
            'Easy conversational pace',
            'Relaxed breathing',
            'Walk breaks allowed'
          ]),
      TrainingDay(
          dayIndex: 4,
          title: 'Strength support',
          workoutType: 'Strength',
          durationMinutes: 35,
          focus: 'Strength',
          exercises: [
            'Squat · 3×10',
            'Step-up · 3×10',
            'Calf raise · 3×15',
            'Row · 3×12',
            'Plank · 3×30 sec'
          ]),
      TrainingDay(
          dayIndex: 5,
          title: 'Tempo progression',
          workoutType: 'Running',
          durationMinutes: 32,
          focus: 'Tempo',
          exercises: ['8 min easy', '16 min comfortably hard', '8 min easy']),
      TrainingDay(
          dayIndex: 6,
          title: 'Long easy run',
          workoutType: 'Running',
          durationMinutes: 40,
          focus: 'Endurance',
          exercises: [
            'Stay relaxed',
            'Keep pace sustainable',
            'Hydrate afterward'
          ]),
      TrainingDay(
          dayIndex: 7,
          title: 'Recovery walk',
          workoutType: 'Walking',
          durationMinutes: 25,
          focus: 'Recovery',
          exercises: ['Easy pace', 'Light mobility afterward']),
    ],
  ),
  TrainingPlan(
    id: 'strength-builder',
    title: 'Strength Builder',
    tagline: 'Progressive full-body resistance training with smart recovery.',
    level: 'Intermediate',
    durationWeeks: 8,
    accentKey: 'coral',
    days: [
      TrainingDay(
          dayIndex: 1,
          title: 'Lower body power',
          workoutType: 'Strength',
          durationMinutes: 50,
          focus: 'Lower body',
          exercises: [
            'Squat · 4×6',
            'Romanian deadlift · 4×8',
            'Walking lunge · 3×10',
            'Calf raise · 4×12'
          ]),
      TrainingDay(
          dayIndex: 2,
          title: 'Upper push',
          workoutType: 'Gym',
          durationMinutes: 45,
          focus: 'Push',
          exercises: [
            'Bench press · 4×6',
            'Overhead press · 3×8',
            'Incline press · 3×10',
            'Triceps pressdown · 3×12'
          ]),
      TrainingDay(
          dayIndex: 3,
          title: 'Active recovery',
          workoutType: 'Walking',
          durationMinutes: 30,
          focus: 'Recovery',
          exercises: ['Easy walk', 'Hip mobility', 'Thoracic mobility']),
      TrainingDay(
          dayIndex: 4,
          title: 'Upper pull',
          workoutType: 'Gym',
          durationMinutes: 45,
          focus: 'Pull',
          exercises: [
            'Pull-up / pulldown · 4×6',
            'Barbell row · 4×8',
            'Rear delt fly · 3×12',
            'Curl · 3×12'
          ]),
      TrainingDay(
          dayIndex: 5,
          title: 'Lower hypertrophy',
          workoutType: 'Strength',
          durationMinutes: 50,
          focus: 'Lower body',
          exercises: [
            'Front squat · 3×10',
            'Hip thrust · 4×10',
            'Leg curl · 3×12',
            'Split squat · 3×10'
          ]),
      TrainingDay(
          dayIndex: 6,
          title: 'Conditioning',
          workoutType: 'Cardio',
          durationMinutes: 28,
          focus: 'Work capacity',
          exercises: [
            '6 rounds moderate-hard',
            '60 sec work / 60 sec easy',
            'Finish with 5 min cooldown'
          ]),
      TrainingDay(
          dayIndex: 7,
          title: 'Mobility',
          workoutType: 'Yoga',
          durationMinutes: 25,
          focus: 'Mobility',
          exercises: ['Full-body mobility flow', 'Slow nasal breathing']),
    ],
  ),
];

TrainingPlan planById(String id) {
  return trainingPlans.firstWhere(
    (plan) => plan.id == id,
    orElse: () => trainingPlans.first,
  );
}
