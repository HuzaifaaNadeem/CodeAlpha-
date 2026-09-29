import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../domain/entities/training_plan.dart';
import '../controllers/fitness_controller.dart';
import '../widgets/workout_visuals.dart';
import 'workout_session_screen.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fitnessControllerProvider);
    final controller = ref.read(fitnessControllerProvider.notifier);
    if (state.isLoading || state.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final plan = controller.activePlan;
    final today = plan.dayFor(DateTime.now());
    final week = controller.recentRecords();
    final weekSessions =
        week.fold<int>(0, (sum, record) => sum + record.workouts.length);
    final target = state.profile!.weeklyWorkoutGoal;

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
                          Text('Train',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          Text('A plan for today. Momentum for the week.',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.mint.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '$weekSessions/$target this week',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _TodayPlanCard(plan: plan, day: today),
                const SizedBox(height: 24),
                Text('This week',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                    '${plan.title} · ${plan.level} · ${plan.durationWeeks} weeks',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                ...plan.days.map((day) {
                  final isToday = day.dayIndex == DateTime.now().weekday;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: PremiumCard(
                      padding: const EdgeInsets.all(14),
                      backgroundColor:
                          isToday ? const Color(0xFFF0F8F4) : Colors.white,
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: workoutColor(day.workoutType)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(workoutIcon(day.workoutType),
                                color: workoutColor(day.workoutType), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(day.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium)),
                                    if (isToday)
                                      const Text('TODAY',
                                          style: TextStyle(
                                              color: AppTheme.primary,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.8)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                    '${day.durationMinutes} min · ${day.focus}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 11.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: Text('Programs',
                            style: Theme.of(context).textTheme.titleLarge)),
                    Text('${trainingPlans.length} plans',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 12),
                ...trainingPlans.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanChoiceCard(
                        plan: item,
                        active: item.id == plan.id,
                        onSelect: () => controller.selectTrainingPlan(item.id),
                      ),
                    )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayPlanCard extends StatelessWidget {
  const _TodayPlanCard({required this.plan, required this.day});

  final TrainingPlan plan;
  final TrainingDay day;

  @override
  Widget build(BuildContext context) {
    final color = workoutColor(day.workoutType);
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
              offset: const Offset(0, 14)),
        ],
      ),
      child: Column(
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
                child: const Text('TODAY’S SESSION',
                    style: TextStyle(
                        color: AppTheme.lime,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8)),
              ),
              const Spacer(),
              Text(plan.title,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(17)),
                child:
                    Icon(workoutIcon(day.workoutType), color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.7)),
                    const SizedBox(height: 6),
                    Text('${day.durationMinutes} min · ${day.focus}',
                        style: const TextStyle(
                            color: Color(0xFFAEBAB6),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...day.exercises.take(4).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: AppTheme.lime, size: 17),
                    const SizedBox(width: 9),
                    Expanded(
                        child: Text(item,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600))),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WorkoutSessionScreen(
                    initialType: day.workoutType,
                    targetMinutes: day.durationMinutes,
                    planId: plan.id,
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.lime, foregroundColor: AppTheme.ink),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start planned workout'),
          ),
        ],
      ),
    );
  }
}

class _PlanChoiceCard extends StatelessWidget {
  const _PlanChoiceCard(
      {required this.plan, required this.active, required this.onSelect});
  final TrainingPlan plan;
  final bool active;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      backgroundColor: active ? const Color(0xFFF0F8F4) : Colors.white,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: active ? AppTheme.primary : AppTheme.surfaceSoft,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
                active
                    ? Icons.auto_awesome_rounded
                    : Icons.calendar_month_rounded,
                color: active ? Colors.white : AppTheme.primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(plan.title,
                            style: Theme.of(context).textTheme.titleMedium)),
                    if (active)
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primary, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(plan.tagline,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 11.5)),
                const SizedBox(height: 7),
                Text('${plan.level} · ${plan.durationWeeks} weeks',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
              onPressed: active ? null : onSelect,
              child: Text(active ? 'Active' : 'Select')),
        ],
      ),
    );
  }
}
