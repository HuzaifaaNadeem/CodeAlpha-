import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../domain/entities/fitness_profile.dart';
import '../controllers/fitness_controller.dart';
import '../controllers/step_sensor_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    FitnessProfile profile,
  ) async {
    final name = TextEditingController(text: profile.name);
    final age = TextEditingController(text: '${profile.age}');
    final height =
        TextEditingController(text: profile.heightCm.toStringAsFixed(0));
    final weight =
        TextEditingController(text: profile.weightKg.toStringAsFixed(1));
    final targetWeight =
        TextEditingController(text: profile.targetWeightKg.toStringAsFixed(1));
    final steps = TextEditingController(text: '${profile.stepGoal}');
    final active = TextEditingController(text: '${profile.activeMinuteGoal}');
    final calories = TextEditingController(text: '${profile.calorieGoal}');
    final water = TextEditingController(text: '${profile.waterGoalMl}');
    final sleep = TextEditingController(text: '${profile.sleepGoalMinutes}');
    final intake = TextEditingController(text: '${profile.calorieIntakeGoal}');
    final protein = TextEditingController(text: '${profile.proteinGoalGrams}');
    final workouts =
        TextEditingController(text: '${profile.weeklyWorkoutGoal}');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.canvas,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.outline,
                          borderRadius: BorderRadius.circular(99)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Personalize PulseFit',
                      style: Theme.of(sheetContext).textTheme.headlineSmall),
                  const SizedBox(height: 5),
                  Text(
                      'Set performance, nutrition, recovery, and body targets.',
                      style: Theme.of(sheetContext).textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  Text('Profile',
                      style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  TextField(
                      controller: name,
                      decoration:
                          const InputDecoration(labelText: 'Display name')),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: age,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Age'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                            controller: height,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Height', suffixText: 'cm'))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: weight,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                                labelText: 'Weight', suffixText: 'kg'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                            controller: targetWeight,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                                labelText: 'Target', suffixText: 'kg'))),
                  ]),
                  const SizedBox(height: 18),
                  Text('Daily performance goals',
                      style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  TextField(
                      controller: steps,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Step goal')),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: active,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Active minutes'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                            controller: calories,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Workout kcal'))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: water,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Water', suffixText: 'ml'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                            controller: sleep,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Sleep goal', suffixText: 'min'))),
                  ]),
                  const SizedBox(height: 18),
                  Text('Nutrition & training',
                      style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: intake,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Daily intake',
                                suffixText: 'kcal'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                            controller: protein,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Protein', suffixText: 'g'))),
                  ]),
                  const SizedBox(height: 10),
                  TextField(
                      controller: workouts,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Weekly workout goal')),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () async {
                      final updated = profile.copyWith(
                        name: name.text.trim().isEmpty
                            ? profile.name
                            : name.text.trim(),
                        age: int.tryParse(age.text) ?? profile.age,
                        heightCm:
                            double.tryParse(height.text) ?? profile.heightCm,
                        weightKg:
                            double.tryParse(weight.text) ?? profile.weightKg,
                        targetWeightKg: double.tryParse(targetWeight.text) ??
                            profile.targetWeightKg,
                        stepGoal: int.tryParse(steps.text) ?? profile.stepGoal,
                        activeMinuteGoal: int.tryParse(active.text) ??
                            profile.activeMinuteGoal,
                        calorieGoal:
                            int.tryParse(calories.text) ?? profile.calorieGoal,
                        waterGoalMl:
                            int.tryParse(water.text) ?? profile.waterGoalMl,
                        sleepGoalMinutes: int.tryParse(sleep.text) ??
                            profile.sleepGoalMinutes,
                        calorieIntakeGoal: int.tryParse(intake.text) ??
                            profile.calorieIntakeGoal,
                        proteinGoalGrams: int.tryParse(protein.text) ??
                            profile.proteinGoalGrams,
                        weeklyWorkoutGoal: int.tryParse(workouts.text) ??
                            profile.weeklyWorkoutGoal,
                      );
                      await ref
                          .read(fitnessControllerProvider.notifier)
                          .updateProfile(updated);
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save profile & goals'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    name.dispose();
    age.dispose();
    height.dispose();
    weight.dispose();
    targetWeight.dispose();
    steps.dispose();
    active.dispose();
    calories.dispose();
    water.dispose();
    sleep.dispose();
    intake.dispose();
    protein.dispose();
    workouts.dispose();
  }

  Future<void> _copyExport(
      BuildContext context, String data, String label) async {
    await Clipboard.setData(ClipboardData(text: data));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label copied to clipboard')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fitnessControllerProvider);
    final sensor = ref.watch(stepSensorControllerProvider);
    final sensorController = ref.read(stepSensorControllerProvider.notifier);
    final controller = ref.read(fitnessControllerProvider.notifier);

    if (state.isLoading || state.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = state.profile!;
    final today = controller.recordFor(DateTime.now());
    final plan = controller.activePlan;
    final achievements = controller.achievements();
    final unlocked = achievements.where((item) => item.unlocked).length;
    final heightM = profile.heightCm / 100;
    final bmi = heightM > 0 ? profile.weightKg / (heightM * heightM) : 0.0;
    final targetDelta = profile.weightKg - profile.targetWeightKg;

    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        children: [
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('You',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Profile, goals, sensors, privacy, and data.',
                      style: Theme.of(context).textTheme.bodyMedium),
                ])),
            IconButton.filledTonal(
                onPressed: () => _editProfile(context, ref, profile),
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Edit profile'),
          ]),
          const SizedBox(height: 22),
          PremiumCard(
            backgroundColor: AppTheme.ink,
            child: Row(children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: AppTheme.lime, shape: BoxShape.circle),
                child: Text(
                    profile.name.isEmpty
                        ? 'P'
                        : profile.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 25,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 15),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(profile.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                        '${profile.weightKg.toStringAsFixed(1)} kg · ${profile.heightCm.toStringAsFixed(0)} cm · ${profile.age} yrs',
                        style: const TextStyle(
                            color: Color(0xFFAEBAB6),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Text(
                        'BMI ${bmi.toStringAsFixed(1)} · ${targetDelta.abs().toStringAsFixed(1)} kg ${targetDelta >= 0 ? 'to target' : 'below target'}',
                        style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                        '$unlocked/${achievements.length} achievements · ${plan.title}',
                        style: const TextStyle(
                            color: AppTheme.lime,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800)),
                  ])),
            ]),
          ),
          const SizedBox(height: 22),
          Text('Live sensor', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 11),
          PremiumCard(
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: sensor.connected
                        ? AppTheme.mint.withValues(alpha: 0.35)
                        : AppTheme.surfaceSoft,
                    borderRadius: BorderRadius.circular(15)),
                child: Icon(
                    sensor.connected
                        ? Icons.sensors_rounded
                        : Icons.sensors_off_rounded,
                    color:
                        sensor.connected ? AppTheme.primary : AppTheme.muted),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        sensor.connected
                            ? (sensor.isDemo
                                ? 'Browser step demo'
                                : 'Phone pedometer')
                            : 'Live step tracking',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(sensor.message,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 11)),
                  ])),
              const SizedBox(width: 8),
              TextButton(
                onPressed: sensor.isConnecting
                    ? null
                    : () async {
                        if (sensor.connected) {
                          await sensorController.disconnect();
                        } else {
                          await sensorController.connect();
                        }
                      },
                child: Text(sensor.connected ? 'Disconnect' : 'Connect'),
              ),
            ]),
          ),
          const SizedBox(height: 22),
          Text('Performance targets',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 11),
          PremiumCard(
            child: Column(children: [
              _GoalRow(
                  icon: Icons.directions_walk_rounded,
                  label: 'Steps',
                  value: '${profile.stepGoal}'),
              const Divider(height: 24),
              _GoalRow(
                  icon: Icons.bolt_rounded,
                  label: 'Active minutes',
                  value: '${profile.activeMinuteGoal} min'),
              const Divider(height: 24),
              _GoalRow(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Workout calories',
                  value: '${profile.calorieGoal} kcal'),
              const Divider(height: 24),
              _GoalRow(
                  icon: Icons.water_drop_rounded,
                  label: 'Hydration',
                  value: '${profile.waterGoalMl} ml'),
              const Divider(height: 24),
              _GoalRow(
                  icon: Icons.bedtime_rounded,
                  label: 'Sleep',
                  value:
                      '${profile.sleepGoalMinutes ~/ 60}h ${profile.sleepGoalMinutes % 60}m'),
              const Divider(height: 24),
              _GoalRow(
                  icon: Icons.restaurant_rounded,
                  label: 'Nutrition',
                  value:
                      '${profile.calorieIntakeGoal} kcal · ${profile.proteinGoalGrams}g protein'),
              const Divider(height: 24),
              _GoalRow(
                  icon: Icons.fitness_center_rounded,
                  label: 'Weekly sessions',
                  value: '${profile.weeklyWorkoutGoal}'),
            ]),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _editProfile(context, ref, profile),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.outline),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17))),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit profile & goals'),
          ),
          const SizedBox(height: 22),
          Text('Today’s body & recovery',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 11),
          PremiumCard(
            child: Wrap(spacing: 18, runSpacing: 18, children: [
              _MiniMetric(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value:
                      '${(today.weightKg > 0 ? today.weightKg : profile.weightKg).toStringAsFixed(1)} kg'),
              _MiniMetric(
                  icon: Icons.favorite_rounded,
                  label: 'Resting HR',
                  value: today.restingHeartRate > 0
                      ? '${today.restingHeartRate} bpm'
                      : 'Not logged'),
              _MiniMetric(
                  icon: Icons.bedtime_rounded,
                  label: 'Sleep',
                  value: today.sleepMinutes > 0
                      ? '${today.sleepHours}h ${today.sleepRemainderMinutes}m'
                      : 'Not logged'),
              _MiniMetric(
                  icon: Icons.self_improvement_rounded,
                  label: 'Mindful',
                  value: '${today.mindfulMinutes} min'),
            ]),
          ),
          const SizedBox(height: 22),
          Text('Data & privacy', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 11),
          PremiumCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.lock_rounded, color: AppTheme.primary, size: 21),
                SizedBox(width: 10),
                Expanded(
                    child: Text(
                        'Your training, nutrition, recovery, and profile data are stored locally on this device.',
                        style: TextStyle(
                            color: AppTheme.ink,
                            fontSize: 13.5,
                            height: 1.4,
                            fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton.icon(
                    onPressed: () => _copyExport(
                        context, controller.exportCsv(), 'CSV export'),
                    icon: const Icon(Icons.table_view_rounded, size: 18),
                    label: const Text('Copy CSV')),
                OutlinedButton.icon(
                    onPressed: () => _copyExport(
                        context, controller.exportJson(), 'JSON backup'),
                    icon: const Icon(Icons.data_object_rounded, size: 18),
                    label: const Text('Copy JSON')),
              ]),
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Reset local data?'),
                      content: const Text(
                          'This removes your local history and restores the rich demo dataset.'),
                      actions: [
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancel')),
                        FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('Reset')),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await controller.reset();
                  }
                },
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset demo data'),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          PremiumCard(
            backgroundColor: const Color(0xFFFFF8E8),
            child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppTheme.amber, size: 21),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          'PulseFit is a wellness and fitness tracker, not a medical device. Resting heart rate and wellness scores are user-entered or sensor-derived fitness signals and should not be used for diagnosis.',
                          style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 11.5,
                              height: 1.45,
                              fontWeight: FontWeight.w600))),
                ]),
          ),
          const SizedBox(height: 28),
          Center(
              child: Text('PulseFit MAX · Signature Performance OS',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10.5))),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: AppTheme.surfaceSoft,
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppTheme.primary, size: 19)),
      const SizedBox(width: 12),
      Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
      Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 13))),
    ]);
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: Row(children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppTheme.surfaceSoft,
                borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: AppTheme.primary, size: 18)),
        const SizedBox(width: 9),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 13)),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 10))
        ])),
      ]),
    );
  }
}
