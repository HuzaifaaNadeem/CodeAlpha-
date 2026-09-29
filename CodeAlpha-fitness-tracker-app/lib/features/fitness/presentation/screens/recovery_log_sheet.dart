import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/fitness_controller.dart';

class RecoveryLogSheet extends ConsumerStatefulWidget {
  const RecoveryLogSheet({super.key});

  @override
  ConsumerState<RecoveryLogSheet> createState() => _RecoveryLogSheetState();
}

class _RecoveryLogSheetState extends ConsumerState<RecoveryLogSheet> {
  int _sleepMinutes = 480;
  int _heartRate = 60;
  int _mood = 4;
  int _mindful = 10;
  late final TextEditingController _weight;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(fitnessControllerProvider).profile;
    final today =
        ref.read(fitnessControllerProvider.notifier).recordFor(DateTime.now());
    _sleepMinutes = today.sleepMinutes > 0
        ? today.sleepMinutes
        : (profile?.sleepGoalMinutes ?? 480);
    _heartRate = today.restingHeartRate > 0 ? today.restingHeartRate : 60;
    _mood = today.moodScore > 0 ? today.moodScore : 4;
    _mindful = today.mindfulMinutes;
    _weight = TextEditingController(
      text: (today.weightKg > 0 ? today.weightKg : (profile?.weightKg ?? 70))
          .toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
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
              Text('Recovery check-in',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 5),
              Text('Log simple wellness signals for smarter trends.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 18),
              _SliderField(
                label: 'Sleep',
                value: _sleepMinutes.toDouble(),
                min: 180,
                max: 720,
                divisions: 36,
                display: '${_sleepMinutes ~/ 60}h ${_sleepMinutes % 60}m',
                onChanged: (value) =>
                    setState(() => _sleepMinutes = value.round()),
              ),
              _SliderField(
                label: 'Resting heart rate',
                value: _heartRate.toDouble(),
                min: 40,
                max: 110,
                divisions: 70,
                display: '$_heartRate bpm',
                onChanged: (value) =>
                    setState(() => _heartRate = value.round()),
              ),
              const SizedBox(height: 8),
              Text('Mood', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (index) {
                  final value = index + 1;
                  final selected = value == _mood;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == 4 ? 0 : 8),
                      child: InkWell(
                        onTap: () => setState(() => _mood = value),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 52,
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.ink : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color:
                                    selected ? AppTheme.ink : AppTheme.outline),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            ['😞', '😕', '🙂', '😊', '🔥'][index],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              _SliderField(
                label: 'Mindful minutes',
                value: _mindful.toDouble(),
                min: 0,
                max: 60,
                divisions: 12,
                display: '$_mindful min',
                onChanged: (value) => setState(() => _mindful = value.round()),
              ),
              TextField(
                controller: _weight,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Body weight',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(fitnessControllerProvider.notifier)
                      .logRecovery(
                        sleepMinutes: _sleepMinutes,
                        restingHeartRate: _heartRate,
                        moodScore: _mood,
                        mindfulMinutes: _mindful,
                        weightKg: double.tryParse(_weight.text),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.bedtime_rounded),
                label: const Text('Save recovery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(label,
                      style: Theme.of(context).textTheme.titleMedium)),
              Text(display,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged),
        ],
      ),
    );
  }
}
