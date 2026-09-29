import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/daily_record.dart';
import '../controllers/fitness_controller.dart';
import '../widgets/week_bar_chart.dart';

enum _InsightMetric { steps, calories, minutes, sleep }

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  _InsightMetric _metric = _InsightMetric.steps;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fitnessControllerProvider);
    final controller = ref.read(fitnessControllerProvider.notifier);

    if (state.isLoading || state.snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = state.snapshot!.profile;
    final records = controller.recentRecords();
    final allRecords = state.snapshot!.records.values.toList();
    final workouts = controller.allWorkouts();
    final achievements = controller.achievements();
    final unlocked = achievements.where((item) => item.unlocked).length;
    final totalSteps = records.fold<int>(0, (sum, item) => sum + item.steps);
    final totalMinutes =
        records.fold<int>(0, (sum, item) => sum + item.activeMinutes);
    final totalCalories =
        records.fold<int>(0, (sum, item) => sum + item.workoutCalories);
    final averageSteps = (totalSteps / records.length).round();
    final goalsHit =
        records.where((item) => item.steps >= profile.stepGoal).length;
    final streak = controller.currentStepStreak();
    final weekWorkouts =
        records.fold<int>(0, (sum, item) => sum + item.workouts.length);
    final averageWellness = (records.fold<int>(
                0, (sum, item) => sum + controller.wellnessScore(item)) /
            records.length)
        .round();
    final averageSleep =
        (records.fold<int>(0, (sum, item) => sum + item.sleepMinutes) /
                records.length)
            .round();
    final averageWater =
        (records.fold<int>(0, (sum, item) => sum + item.waterMl) /
                records.length)
            .round();
    final bestSteps = allRecords.fold<int>(
        0, (best, item) => item.steps > best ? item.steps : best);
    final longestWorkout = workouts.fold<int>(
        0,
        (best, item) =>
            item.durationMinutes > best ? item.durationMinutes : best);
    final bestCalories = workouts.fold<int>(
        0, (best, item) => item.calories > best ? item.calories : best);

    final metricGoal = switch (_metric) {
      _InsightMetric.steps => profile.stepGoal,
      _InsightMetric.calories => profile.calorieGoal,
      _InsightMetric.minutes => profile.activeMinuteGoal,
      _InsightMetric.sleep => profile.sleepGoalMinutes,
    };
    final metricValue = switch (_metric) {
      _InsightMetric.steps => (DailyRecord item) => item.steps,
      _InsightMetric.calories => (DailyRecord item) => item.workoutCalories,
      _InsightMetric.minutes => (DailyRecord item) => item.activeMinutes,
      _InsightMetric.sleep => (DailyRecord item) => item.sleepMinutes,
    };
    final metricLabel = switch (_metric) {
      _InsightMetric.steps => (int value) =>
          value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : '$value',
      _InsightMetric.calories => (int value) => '$value',
      _InsightMetric.minutes => (int value) => '${value}m',
      _InsightMetric.sleep => (int value) =>
          '${(value / 60).toStringAsFixed(1)}h',
    };
    final chartTitle = switch (_metric) {
      _InsightMetric.steps => 'Steps this week',
      _InsightMetric.calories => 'Workout calories',
      _InsightMetric.minutes => 'Active minutes',
      _InsightMetric.sleep => 'Sleep duration',
    };
    final chartSubtitle = switch (_metric) {
      _InsightMetric.steps => '$totalSteps total · $averageSteps daily average',
      _InsightMetric.calories => '$totalCalories kcal across the last 7 days',
      _InsightMetric.minutes => '$totalMinutes active minutes this week',
      _InsightMetric.sleep =>
        '${(averageSleep / 60).toStringAsFixed(1)}h nightly average',
    };

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Insights',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          Text(
                              'Trends, records, recovery, and earned milestones.',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 8),
                      decoration: BoxDecoration(
                          color: AppTheme.ink,
                          borderRadius: BorderRadius.circular(99)),
                      child: Text('$unlocked/${achievements.length} badges',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _MomentumStrip(
                    streak: streak,
                    wellness: averageWellness,
                    workouts: weekWorkouts,
                    targetWorkouts: profile.weeklyWorkoutGoal),
                const SizedBox(height: 18),
                SegmentedButton<_InsightMetric>(
                  segments: const [
                    ButtonSegment(
                        value: _InsightMetric.steps,
                        label: Text('Steps'),
                        icon: Icon(Icons.directions_walk_rounded, size: 16)),
                    ButtonSegment(
                        value: _InsightMetric.calories,
                        label: Text('Burn'),
                        icon: Icon(Icons.local_fire_department_rounded,
                            size: 16)),
                    ButtonSegment(
                        value: _InsightMetric.minutes,
                        label: Text('Active'),
                        icon: Icon(Icons.timer_rounded, size: 16)),
                    ButtonSegment(
                        value: _InsightMetric.sleep,
                        label: Text('Sleep'),
                        icon: Icon(Icons.bedtime_rounded, size: 16)),
                  ],
                  selected: {_metric},
                  onSelectionChanged: (value) =>
                      setState(() => _metric = value.first),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle: const WidgetStatePropertyAll(
                        TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 14),
                PremiumCard(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(chartTitle,
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 3),
                                Text(chartSubtitle,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ])),
                          if (_metric == _InsightMetric.steps)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                  color: AppTheme.mint.withValues(alpha: 0.34),
                                  borderRadius: BorderRadius.circular(99)),
                              child: Text('$goalsHit/7 goals',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: AppTheme.primaryDark,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      WeekBarChart(
                          records: records,
                          goal: metricGoal,
                          valueOf: metricValue,
                          labelForValue: metricLabel),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(builder: (context, constraints) {
                  final width = (constraints.maxWidth - 10) / 2;
                  return Wrap(spacing: 10, runSpacing: 10, children: [
                    SizedBox(
                        width: width,
                        child: _InsightCard(
                            icon: Icons.bedtime_rounded,
                            label: 'Avg sleep',
                            value: '${(averageSleep / 60).toStringAsFixed(1)}h',
                            tint: AppTheme.blue)),
                    SizedBox(
                        width: width,
                        child: _InsightCard(
                            icon: Icons.water_drop_rounded,
                            label: 'Avg water',
                            value:
                                '${(averageWater / 1000).toStringAsFixed(1)}L',
                            tint: const Color(0xFF28A9C7))),
                    SizedBox(
                        width: width,
                        child: _InsightCard(
                            icon: Icons.directions_walk_rounded,
                            label: 'Best steps',
                            value: '$bestSteps',
                            tint: AppTheme.primary)),
                    SizedBox(
                        width: width,
                        child: _InsightCard(
                            icon: Icons.timer_rounded,
                            label: 'Longest',
                            value: '$longestWorkout min',
                            tint: AppTheme.amber)),
                  ]);
                }),
                const SizedBox(height: 24),
                Text('Personal records',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                PremiumCard(
                  backgroundColor: AppTheme.ink,
                  child: Row(
                    children: [
                      Expanded(
                          child: _DarkRecord(
                              value: '$bestSteps',
                              label: 'Best steps',
                              icon: Icons.directions_walk_rounded)),
                      Container(width: 1, height: 52, color: Colors.white12),
                      Expanded(
                          child: _DarkRecord(
                              value: '$longestWorkout',
                              label: 'Longest min',
                              icon: Icons.timer_rounded)),
                      Container(width: 1, height: 52, color: Colors.white12),
                      Expanded(
                          child: _DarkRecord(
                              value: '$bestCalories',
                              label: 'Top kcal',
                              icon: Icons.local_fire_department_rounded)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: Text('Achievements',
                          style: Theme.of(context).textTheme.titleLarge)),
                  Text('$unlocked unlocked',
                      style: Theme.of(context).textTheme.bodyMedium),
                ]),
                const SizedBox(height: 12),
                ...achievements.map((achievement) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AchievementCard(achievement: achievement),
                    )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MomentumStrip extends StatelessWidget {
  const _MomentumStrip(
      {required this.streak,
      required this.wellness,
      required this.workouts,
      required this.targetWorkouts});
  final int streak;
  final int wellness;
  final int workouts;
  final int targetWorkouts;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      backgroundColor: const Color(0xFFF0F7F4),
      child: Row(children: [
        Expanded(child: _SummaryStat(value: '$streak', label: 'Day streak')),
        Container(width: 1, height: 44, color: AppTheme.outline),
        Expanded(child: _SummaryStat(value: '$wellness', label: 'Wellness')),
        Container(width: 1, height: 44, color: AppTheme.outline),
        Expanded(
            child: _SummaryStat(
                value: '$workouts/$targetWorkouts', label: 'Workouts')),
      ]),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: AppTheme.primary)),
      const SizedBox(height: 3),
      Text(label,
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10.5),
          textAlign: TextAlign.center),
    ]);
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.tint});
  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(15),
      child: Row(children: [
        Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: tint, size: 19)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 10.5))
        ])),
      ]),
    );
  }
}

class _DarkRecord extends StatelessWidget {
  const _DarkRecord(
      {required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: AppTheme.lime, size: 20),
      const SizedBox(height: 7),
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(
              color: Colors.white54,
              fontSize: 9.5,
              fontWeight: FontWeight.w700),
          textAlign: TextAlign.center),
    ]);
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});
  final Achievement achievement;

  IconData _icon() {
    return switch (achievement.iconKey) {
      'steps' => Icons.directions_walk_rounded,
      'shield' => Icons.shield_rounded,
      'route' => Icons.route_rounded,
      'water' => Icons.water_drop_rounded,
      'medal' => Icons.workspace_premium_rounded,
      'timer' => Icons.timer_rounded,
      'sun' => Icons.wb_sunny_rounded,
      _ => Icons.bolt_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    return PremiumCard(
      backgroundColor: unlocked ? const Color(0xFFF2F9F5) : Colors.white,
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: unlocked ? AppTheme.lime : AppTheme.surfaceSoft,
              borderRadius: BorderRadius.circular(15)),
          child: Icon(_icon(),
              color: unlocked ? AppTheme.ink : AppTheme.muted, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(achievement.title,
                    style: Theme.of(context).textTheme.titleMedium)),
            Text(
                unlocked
                    ? 'UNLOCKED'
                    : '${(achievement.progress * 100).round()}%',
                style: TextStyle(
                    color: unlocked ? AppTheme.primary : AppTheme.muted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6)),
          ]),
          const SizedBox(height: 3),
          Text(achievement.description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 11)),
          const SizedBox(height: 8),
          ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                  value: achievement.progress.clamp(0, 1).toDouble(),
                  minHeight: 5,
                  color: unlocked ? AppTheme.primary : AppTheme.mint,
                  backgroundColor: AppTheme.surfaceSoft)),
        ])),
      ]),
    );
  }
}
