import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../domain/entities/daily_record.dart';
import '../controllers/fitness_controller.dart';
import '../controllers/step_sensor_controller.dart';
import '../widgets/metric_chip.dart';
import '../widgets/progress_ring.dart';
import '../widgets/workout_tile.dart';
import 'nutrition_log_sheet.dart';
import 'quick_add_sheet.dart';
import 'recovery_log_sheet.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  String _dateLabel() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  Future<void> _showSheet(BuildContext context, Widget child) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fitnessControllerProvider);
    final controller = ref.read(fitnessControllerProvider.notifier);
    final sensor = ref.watch(stepSensorControllerProvider);
    final sensorController = ref.read(stepSensorControllerProvider.notifier);

    if (state.isLoading || state.snapshot == null) {
      return const _TodayLoading();
    }

    final profile = state.snapshot!.profile;
    final record = controller.recordFor(DateTime.now());
    final wellness = controller.wellnessScore(record);
    final stepProgress = record.steps / profile.stepGoal;
    final activeProgress = record.activeMinutes / profile.activeMinuteGoal;
    final calorieProgress = record.workoutCalories / profile.calorieGoal;
    final waterProgress = record.waterMl / profile.waterGoalMl;
    final intakeProgress = record.caloriesConsumed / profile.calorieIntakeGoal;
    final proteinProgress = record.proteinGrams / profile.proteinGoalGrams;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 132),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _AppHeader(record: record, stepGoal: profile.stepGoal),
                const SizedBox(height: 24),
                Text(
                  '${_greeting()}, ${profile.name}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 5),
                Text(_dateLabel(),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 18),
                _MovementHero(
                  record: record,
                  stepGoal: profile.stepGoal,
                  stepProgress: stepProgress,
                  sensor: sensor,
                  onSensorTap: () async {
                    await HapticFeedback.selectionClick();
                    if (sensor.connected) {
                      await sensorController.disconnect();
                    } else {
                      await sensorController.connect();
                    }
                  },
                ),
                const SizedBox(height: 13),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    MetricChip(
                        icon: Icons.route_rounded,
                        value: '${record.distanceKm.toStringAsFixed(1)} km',
                        label: 'Distance',
                        tint: AppTheme.blue),
                    MetricChip(
                        icon: Icons.local_fire_department_rounded,
                        value: '${record.workoutCalories} kcal',
                        label: 'Workout burn',
                        tint: AppTheme.coral),
                    MetricChip(
                        icon: Icons.timer_rounded,
                        value: '${record.activeMinutes} min',
                        label: 'Active',
                        tint: AppTheme.primary),
                    MetricChip(
                        icon: Icons.stairs_rounded,
                        value: '${record.floorsClimbed}',
                        label: 'Floors',
                        tint: AppTheme.amber),
                  ],
                ),
                const SizedBox(height: 25),
                _SectionHeader(
                    title: 'Today at a glance',
                    subtitle: 'Movement, fuel, hydration, and recovery.'),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 700) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _WellnessCard(
                              score: wellness,
                              record: record,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GoalGrid(
                              activeProgress: activeProgress,
                              calorieProgress: calorieProgress,
                              record: record,
                              activeGoal: profile.activeMinuteGoal,
                              calorieGoal: profile.calorieGoal,
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _WellnessCard(score: wellness, record: record),
                        const SizedBox(height: 12),
                        _GoalGrid(
                          activeProgress: activeProgress,
                          calorieProgress: calorieProgress,
                          record: record,
                          activeGoal: profile.activeMinuteGoal,
                          calorieGoal: profile.calorieGoal,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                    title: 'Quick actions',
                    subtitle: 'Log the things that shape your day.'),
                const SizedBox(height: 12),
                _QuickActions(
                  onWorkout: () => _showSheet(context, const QuickAddSheet()),
                  onNutrition: () =>
                      _showSheet(context, const NutritionLogSheet()),
                  onRecovery: () =>
                      _showSheet(context, const RecoveryLogSheet()),
                  onWater: () => controller.addWater(250),
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                    title: 'Fuel & hydration',
                    subtitle: 'Simple macro and water awareness.'),
                const SizedBox(height: 12),
                _FuelCard(
                  record: record,
                  intakeGoal: profile.calorieIntakeGoal,
                  proteinGoal: profile.proteinGoalGrams,
                  waterGoal: profile.waterGoalMl,
                  intakeProgress: intakeProgress,
                  proteinProgress: proteinProgress,
                  waterProgress: waterProgress,
                  onNutrition: () =>
                      _showSheet(context, const NutritionLogSheet()),
                  onWater: () => controller.addWater(250),
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Today’s activity',
                  subtitle: record.workouts.isEmpty
                      ? 'No workouts logged yet.'
                      : '${record.workouts.length} session${record.workouts.length == 1 ? '' : 's'} completed',
                  trailing: TextButton(
                    onPressed: () => _showSheet(context, const QuickAddSheet()),
                    child: const Text('Quick add'),
                  ),
                ),
                const SizedBox(height: 12),
                if (record.workouts.isEmpty)
                  const _EmptyWorkoutState()
                else
                  ...record.workouts.reversed.map(
                    (workout) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: WorkoutTile(workout: workout),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.record, required this.stepGoal});
  final DailyRecord record;
  final int stepGoal;

  @override
  Widget build(BuildContext context) {
    final reached = record.steps >= stepGoal;
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
              color: AppTheme.ink, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.monitor_heart_rounded,
              color: AppTheme.lime, size: 22),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PulseFit', style: Theme.of(context).textTheme.titleMedium),
              const Text('MAX · PERFORMANCE OS',
                  style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.05)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color:
                reached ? AppTheme.mint.withValues(alpha: 0.35) : Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppTheme.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(reached ? Icons.check_circle_rounded : Icons.bolt_rounded,
                  size: 16, color: reached ? AppTheme.primary : AppTheme.amber),
              const SizedBox(width: 6),
              Text(reached ? 'Goal hit' : 'In progress',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MovementHero extends StatelessWidget {
  const _MovementHero({
    required this.record,
    required this.stepGoal,
    required this.stepProgress,
    required this.sensor,
    required this.onSensorTap,
  });

  final DailyRecord record;
  final int stepGoal;
  final double stepProgress;
  final StepSensorState sensor;
  final VoidCallback onSensorTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: AppTheme.ink.withValues(alpha: 0.14),
              blurRadius: 28,
              offset: const Offset(0, 14))
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 520;
          final ring = ProgressRing(
            progress: stepProgress.clamp(0, 1).toDouble(),
            color: AppTheme.lime,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            size: narrow ? 180 : 188,
            strokeWidth: 13,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_walk_rounded,
                    color: AppTheme.lime, size: 25),
                const SizedBox(height: 7),
                Text('${record.steps}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8)),
                const Text('steps',
                    style: TextStyle(
                        color: Color(0xFFB7C2BE),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          );

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppTheme.lime.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(99)),
                    child: const Text('LIVE MOVEMENT',
                        style: TextStyle(
                            color: AppTheme.lime,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8)),
                  ),
                  const SizedBox(width: 8),
                  if (sensor.connected)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: AppTheme.mint, shape: BoxShape.circle),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              const Text('Move with\nintention.',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      height: 1.03,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.1)),
              const SizedBox(height: 10),
              Text(
                  '${(stepProgress * 100).clamp(0, 999).round()}% of your $stepGoal step goal',
                  style: const TextStyle(
                      color: Color(0xFFB7C2BE),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              InkWell(
                onTap: onSensorTap,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Icon(
                          sensor.connected
                              ? Icons.sensors_rounded
                              : Icons.sensors_off_rounded,
                          color:
                              sensor.connected ? AppTheme.lime : Colors.white70,
                          size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sensor.isConnecting
                              ? 'Connecting…'
                              : sensor.connected
                                  ? (sensor.isDemo
                                      ? 'Browser demo live'
                                      : 'Phone sensor live')
                                  : 'Connect live steps',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (sensor.connected && sensor.status != 'connected') ...[
                const SizedBox(height: 8),
                Text('Status · ${sensor.status}',
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ],
            ],
          );

          if (narrow) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  details,
                  const SizedBox(height: 22),
                  Center(child: ring)
                ]);
          }
          return Row(children: [
            Expanded(child: details),
            const SizedBox(width: 18),
            ring
          ]);
        },
      ),
    );
  }
}

class _WellnessCard extends StatelessWidget {
  const _WellnessCard({required this.score, required this.record});
  final int score;
  final DailyRecord record;

  @override
  Widget build(BuildContext context) {
    final sleepLabel = record.sleepMinutes > 0
        ? '${record.sleepHours}h ${record.sleepRemainderMinutes}m'
        : 'Not logged';
    return PremiumCard(
      child: Row(
        children: [
          ProgressRing(
            progress: score / 100,
            color: score >= 80
                ? AppTheme.primary
                : score >= 60
                    ? AppTheme.amber
                    : AppTheme.coral,
            size: 94,
            strokeWidth: 9,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$score', style: Theme.of(context).textTheme.headlineSmall),
              Text('wellness',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 9.5)),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily wellness',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                    'A simple non-medical score based on sleep, hydration, movement, and mood.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 11)),
                const SizedBox(height: 10),
                Wrap(spacing: 12, runSpacing: 5, children: [
                  _InlineStat(icon: Icons.bedtime_rounded, value: sleepLabel),
                  _InlineStat(
                      icon: Icons.favorite_rounded,
                      value: record.restingHeartRate > 0
                          ? '${record.restingHeartRate} bpm'
                          : 'HR —'),
                  _InlineStat(
                      icon: Icons.self_improvement_rounded,
                      value: '${record.mindfulMinutes} min'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({required this.icon, required this.value});
  final IconData icon;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppTheme.primary),
      const SizedBox(width: 4),
      Text(value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontSize: 10.5, fontWeight: FontWeight.w800)),
    ]);
  }
}

class _GoalGrid extends StatelessWidget {
  const _GoalGrid({
    required this.activeProgress,
    required this.calorieProgress,
    required this.record,
    required this.activeGoal,
    required this.calorieGoal,
  });
  final double activeProgress;
  final double calorieProgress;
  final DailyRecord record;
  final int activeGoal;
  final int calorieGoal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _GoalCard(
                label: 'Active',
                value: '${record.activeMinutes}',
                unit: '/ $activeGoal min',
                progress: activeProgress,
                color: AppTheme.primary,
                icon: Icons.bolt_rounded)),
        const SizedBox(width: 10),
        Expanded(
            child: _GoalCard(
                label: 'Burn',
                value: '${record.workoutCalories}',
                unit: '/ $calorieGoal kcal',
                progress: calorieProgress,
                color: AppTheme.coral,
                icon: Icons.local_fire_department_rounded)),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard(
      {required this.label,
      required this.value,
      required this.unit,
      required this.progress,
      required this.color,
      required this.icon});
  final String label;
  final String value;
  final String unit;
  final double progress;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, color: color, size: 18)),
            const Spacer(),
            Text('${(progress * 100).clamp(0, 999).round()}%',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 11, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 2),
          RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.titleLarge,
                  children: [
                TextSpan(text: value),
                TextSpan(
                    text: ' $unit',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 10.5))
              ])),
          const SizedBox(height: 12),
          ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                  value: progress.clamp(0, 1).toDouble(),
                  minHeight: 6,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.10))),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions(
      {required this.onWorkout,
      required this.onNutrition,
      required this.onRecovery,
      required this.onWater});
  final VoidCallback onWorkout;
  final VoidCallback onNutrition;
  final VoidCallback onRecovery;
  final VoidCallback onWater;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - 10) / 2;
      return Wrap(spacing: 10, runSpacing: 10, children: [
        SizedBox(
            width: width,
            child: _ActionTile(
                icon: Icons.add_task_rounded,
                label: 'Log workout',
                subtitle: 'Manual session',
                color: AppTheme.primary,
                onTap: onWorkout)),
        SizedBox(
            width: width,
            child: _ActionTile(
                icon: Icons.restaurant_rounded,
                label: 'Log nutrition',
                subtitle: 'Calories & macros',
                color: AppTheme.coral,
                onTap: onNutrition)),
        SizedBox(
            width: width,
            child: _ActionTile(
                icon: Icons.bedtime_rounded,
                label: 'Recovery',
                subtitle: 'Sleep, HR, mood',
                color: AppTheme.blue,
                onTap: onRecovery)),
        SizedBox(
            width: width,
            child: _ActionTile(
                icon: Icons.water_drop_rounded,
                label: '+250 ml water',
                subtitle: 'Hydration boost',
                color: const Color(0xFF28A9C7),
                onTap: onWater)),
      ]);
    });
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon,
      required this.label,
      required this.subtitle,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: AppTheme.outline)),
          child: Row(children: [
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 19)),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 10.5))
                ])),
          ]),
        ),
      ),
    );
  }
}

class _FuelCard extends StatelessWidget {
  const _FuelCard({
    required this.record,
    required this.intakeGoal,
    required this.proteinGoal,
    required this.waterGoal,
    required this.intakeProgress,
    required this.proteinProgress,
    required this.waterProgress,
    required this.onNutrition,
    required this.onWater,
  });
  final DailyRecord record;
  final int intakeGoal;
  final int proteinGoal;
  final int waterGoal;
  final double intakeProgress;
  final double proteinProgress;
  final double waterProgress;
  final VoidCallback onNutrition;
  final VoidCallback onWater;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          Row(children: [
            Expanded(
                child: _MacroStat(
                    label: 'Calories',
                    value: '${record.caloriesConsumed}',
                    target: '$intakeGoal',
                    color: AppTheme.coral,
                    progress: intakeProgress)),
            const SizedBox(width: 10),
            Expanded(
                child: _MacroStat(
                    label: 'Protein',
                    value: '${record.proteinGrams}g',
                    target: '${proteinGoal}g',
                    color: AppTheme.primary,
                    progress: proteinProgress)),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFFEFF8FB),
                borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              const Icon(Icons.water_drop_rounded,
                  color: Color(0xFF28A9C7), size: 23),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('${record.waterMl} / $waterGoal ml',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                            value: waterProgress.clamp(0, 1).toDouble(),
                            minHeight: 6,
                            color: const Color(0xFF28A9C7),
                            backgroundColor: Colors.white)),
                  ])),
              IconButton(
                  onPressed: onWater,
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'Add 250 ml'),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: Text(
                    'Carbs ${record.carbsGrams}g · Fat ${record.fatGrams}g',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 11.5))),
            TextButton.icon(
                onPressed: onNutrition,
                icon: const Icon(Icons.add_rounded, size: 17),
                label: const Text('Add meal')),
          ]),
        ],
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat(
      {required this.label,
      required this.value,
      required this.target,
      required this.color,
      required this.progress});
  final String label;
  final String value;
  final String target;
  final Color color;
  final double progress;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 10.5)),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text('goal $target',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 9.5)),
        const SizedBox(height: 9),
        ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
                value: progress.clamp(0, 1).toDouble(),
                minHeight: 5,
                color: color,
                backgroundColor: Colors.white)),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.title, required this.subtitle, this.trailing});
  final String title;
  final String subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 3),
        Text(subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 11.5))
      ])),
      if (trailing != null) trailing!,
    ]);
  }
}

class _EmptyWorkoutState extends StatelessWidget {
  const _EmptyWorkoutState();
  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(children: [
        Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: AppTheme.surfaceSoft,
                borderRadius: BorderRadius.circular(17)),
            child: const Icon(Icons.fitness_center_rounded,
                color: AppTheme.primary)),
        const SizedBox(height: 11),
        Text('Your next session starts here',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Start a live workout or add one manually.',
            style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }
}

class _TodayLoading extends StatelessWidget {
  const _TodayLoading();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _Skeleton(height: 44),
        SizedBox(height: 22),
        _Skeleton(height: 80),
        SizedBox(height: 16),
        _Skeleton(height: 310),
        SizedBox(height: 14),
        _Skeleton(height: 120),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        decoration: BoxDecoration(
            color: AppTheme.surfaceSoft,
            borderRadius: BorderRadius.circular(24)));
  }
}
