import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/workout_catalog.dart';
import '../../domain/entities/workout_entry.dart';
import '../controllers/fitness_controller.dart';
import '../widgets/workout_visuals.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key, this.initial});

  final WorkoutEntry? initial;

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  late String _type;
  late String _intensity;
  late int _duration;
  late final TextEditingController _distance;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _type = widget.initial?.type ?? 'Walking';
    _intensity =
        widget.initial?.intensity ?? catalogItemFor(_type).defaultIntensity;
    _duration = widget.initial?.durationMinutes ?? 30;
    _distance = TextEditingController(
      text: (widget.initial?.distanceKm ?? 0) > 0
          ? widget.initial!.distanceKm.toStringAsFixed(2)
          : '',
    );
    _notes = TextEditingController(text: widget.initial?.notes ?? '');
  }

  @override
  void dispose() {
    _distance.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(fitnessControllerProvider).profile;
    final weightKg = profile?.weightKg ?? 70.0;
    final calories = estimateCalories(
      type: _type,
      durationMinutes: _duration,
      weightKg: weightKg,
      intensity: _intensity,
    );
    final estimatedDistance = estimateDistanceKm(
      type: _type,
      durationMinutes: _duration,
      intensity: _intensity,
    );
    final editing = widget.initial != null;

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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outline,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                editing ? 'Edit activity' : 'Quick add activity',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 5),
              Text(
                'Calories are estimated from activity, duration, intensity, and your saved body weight.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: workoutCatalog.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final type = workoutCatalog[index].name;
                    final selected = type == _type;
                    final color = workoutColor(type);
                    return ChoiceChip(
                      selected: selected,
                      onSelected: (_) => setState(() {
                        _type = type;
                        _intensity = catalogItemFor(type).defaultIntensity;
                      }),
                      avatar: Icon(
                        workoutIcon(type),
                        size: 17,
                        color: selected ? Colors.white : color,
                      ),
                      label: Text(type),
                      selectedColor: color,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppTheme.ink,
                        fontWeight: FontWeight.w800,
                      ),
                      side: BorderSide(
                          color: selected ? color : AppTheme.outline),
                      backgroundColor: Colors.white,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _StepperRow(
                label: 'Duration',
                value: '$_duration min',
                onMinus: () => setState(
                  () => _duration = (_duration - 5).clamp(5, 360).toInt(),
                ),
                onPlus: () => setState(
                  () => _duration = (_duration + 5).clamp(5, 360).toInt(),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Light', label: Text('Light')),
                  ButtonSegment(value: 'Moderate', label: Text('Moderate')),
                  ButtonSegment(value: 'Hard', label: Text('Hard')),
                ],
                selected: {_intensity},
                onSelectionChanged: (value) =>
                    setState(() => _intensity = value.first),
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _distance,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Distance (optional)',
                  suffixText: 'km',
                  hintText: estimatedDistance > 0
                      ? 'Estimated ${estimatedDistance.toStringAsFixed(2)}'
                      : 'Not applicable',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notes,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Session notes (optional)',
                  hintText: 'How did it feel? Any highlights?',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppTheme.ink,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.lime.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppTheme.lime,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated burn',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$calories kcal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${weightKg.toStringAsFixed(0)} kg · $_intensity',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  final controller =
                      ref.read(fitnessControllerProvider.notifier);
                  final distance =
                      double.tryParse(_distance.text) ?? estimatedDistance;
                  if (editing) {
                    await controller.updateWorkout(
                      widget.initial!,
                      type: _type,
                      durationMinutes: _duration,
                      calories: calories,
                      intensity: _intensity,
                      distanceKm: distance,
                      notes: _notes.text.trim(),
                    );
                  } else {
                    await controller.addWorkout(
                      type: _type,
                      durationMinutes: _duration,
                      calories: calories,
                      intensity: _intensity,
                      distanceKm: distance,
                      notes: _notes.text.trim(),
                    );
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(editing ? Icons.save_rounded : Icons.check_rounded),
                label: Text(editing ? 'Save changes' : 'Add activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          IconButton(
              onPressed: onMinus, icon: const Icon(Icons.remove_rounded)),
          IconButton.filledTonal(
              onPressed: onPlus, icon: const Icon(Icons.add_rounded)),
        ],
      ),
    );
  }
}
