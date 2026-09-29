import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/workout_catalog.dart';
import '../controllers/fitness_controller.dart';
import '../widgets/progress_ring.dart';
import '../widgets/workout_visuals.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({
    super.key,
    this.initialType = 'Running',
    this.targetMinutes,
    this.planId,
  });

  final String initialType;
  final int? targetMinutes;
  final String? planId;

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  late String _type;
  String _intensity = 'Moderate';
  int _seconds = 0;
  bool _running = false;
  Timer? _timer;
  final List<int> _laps = [];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _intensity = catalogItemFor(_type).defaultIntensity;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }

    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _seconds++);
    });
  }

  int _estimatedCalories(double weightKg) {
    if (_seconds == 0) {
      return 0;
    }
    return estimateCalories(
      type: _type,
      durationMinutes: (_seconds / 60).ceil().clamp(1, 600).toInt(),
      weightKg: weightKg,
      intensity: _intensity,
    );
  }

  double _estimatedDistance() {
    if (_seconds == 0) {
      return 0;
    }
    return estimateDistanceKm(
      type: _type,
      durationMinutes: (_seconds / 60).ceil().clamp(1, 600).toInt(),
      intensity: _intensity,
    );
  }

  String _formatClock(int value) {
    final hours = value ~/ 3600;
    final minutes = (value % 3600) ~/ 60;
    final seconds = value % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _addLap() {
    if (_seconds <= 0) {
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _laps.add(_seconds));
  }

  Future<void> _finish() async {
    _timer?.cancel();
    final minutes = (_seconds / 60).ceil().clamp(1, 600).toInt();
    final weightKg =
        ref.read(fitnessControllerProvider).profile?.weightKg ?? 70.0;
    await ref.read(fitnessControllerProvider.notifier).addWorkout(
          type: _type,
          durationMinutes: minutes,
          calories: _estimatedCalories(weightKg),
          intensity: _intensity,
          distanceKm: _estimatedDistance(),
          notes: _laps.isEmpty ? '' : '${_laps.length} lap markers recorded',
          planId: widget.planId,
        );

    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = workoutColor(_type);
    final weightKg =
        ref.watch(fitnessControllerProvider).profile?.weightKg ?? 70.0;
    final estimatedCalories = _estimatedCalories(weightKg);
    final distance = _estimatedDistance();
    final targetSeconds = (widget.targetMinutes ?? 0) * 60;
    final progress = targetSeconds > 0
        ? (_seconds / targetSeconds).clamp(0.0, 1.0).toDouble()
        : (_seconds % 60) / 60;

    return PopScope(
      canPop: !_running,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_running) {
          return;
        }
        final leave = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Workout in progress'),
            content: const Text(
                'Pause or finish the workout before leaving to avoid losing the session.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Stay')),
              TextButton(
                onPressed: () {
                  _timer?.cancel();
                  setState(() => _running = false);
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Pause'),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.ink,
        appBar: AppBar(
          backgroundColor: AppTheme.ink,
          foregroundColor: Colors.white,
          title:
              Text(widget.planId == null ? 'Live Workout' : 'Planned Workout'),
          actions: [
            TextButton(
              onPressed: _seconds == 0 ? null : _finish,
              child: const Text('Finish',
                  style: TextStyle(
                      color: AppTheme.lime, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(
                height: 64,
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: workoutCatalog.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final type = workoutCatalog[index].name;
                    final selected = type == _type;
                    return ChoiceChip(
                      selected: selected,
                      onSelected: _running
                          ? null
                          : (_) => setState(() {
                                _type = type;
                                _intensity =
                                    catalogItemFor(type).defaultIntensity;
                              }),
                      label: Text(type),
                      avatar: Icon(workoutIcon(type),
                          size: 17,
                          color: selected ? AppTheme.ink : Colors.white70),
                      selectedColor: AppTheme.lime,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      side: BorderSide(
                          color: selected
                              ? AppTheme.lime
                              : Colors.white.withValues(alpha: 0.10)),
                      labelStyle: TextStyle(
                          color: selected ? AppTheme.ink : Colors.white,
                          fontWeight: FontWeight.w800),
                    );
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 34),
                  child: Column(
                    children: [
                      Text(
                        _running ? 'SESSION IN PROGRESS' : 'READY WHEN YOU ARE',
                        style: TextStyle(
                            color: _running ? AppTheme.lime : Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2),
                      ),
                      if (widget.targetMinutes != null) ...[
                        const SizedBox(height: 7),
                        Text('Target · ${widget.targetMinutes} minutes',
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700)),
                      ],
                      const SizedBox(height: 22),
                      ProgressRing(
                        progress: progress,
                        color: color,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        size: 230,
                        strokeWidth: 14,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(workoutIcon(_type), color: color, size: 33),
                            const SizedBox(height: 10),
                            Text(_formatClock(_seconds),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 43,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.5)),
                            const SizedBox(height: 3),
                            Text(_type,
                                style: const TextStyle(
                                    color: Color(0xFFAAB6B2),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Light', label: Text('Light')),
                          ButtonSegment(
                              value: 'Moderate', label: Text('Moderate')),
                          ButtonSegment(value: 'Hard', label: Text('Hard')),
                        ],
                        selected: {_intensity},
                        onSelectionChanged: _running
                            ? null
                            : (value) =>
                                setState(() => _intensity = value.first),
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                                  ? AppTheme.ink
                                  : Colors.white70),
                          backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                                  ? AppTheme.lime
                                  : Colors.white.withValues(alpha: 0.05)),
                          side: WidgetStatePropertyAll(BorderSide(
                              color: Colors.white.withValues(alpha: 0.10))),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 32,
                        runSpacing: 16,
                        children: [
                          _LiveMetric(
                              label: 'Calories',
                              value: '$estimatedCalories',
                              unit: 'kcal'),
                          _LiveMetric(
                              label: 'Distance',
                              value: distance > 0
                                  ? distance.toStringAsFixed(2)
                                  : '—',
                              unit: distance > 0 ? 'km' : ''),
                          _LiveMetric(
                              label: 'Laps',
                              value: '${_laps.length}',
                              unit: ''),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 58,
                            height: 58,
                            child: IconButton.filledTonal(
                              onPressed: _seconds == 0 ? null : _addLap,
                              style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.08),
                                  foregroundColor: Colors.white),
                              icon: const Icon(Icons.flag_rounded),
                            ),
                          ),
                          const SizedBox(width: 22),
                          SizedBox(
                            width: 92,
                            height: 92,
                            child: FilledButton(
                              onPressed: _toggle,
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor:
                                    _running ? Colors.white : AppTheme.lime,
                                foregroundColor: AppTheme.ink,
                                shape: const CircleBorder(),
                              ),
                              child: Icon(
                                  _running
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 38),
                            ),
                          ),
                          const SizedBox(width: 22),
                          SizedBox(
                            width: 58,
                            height: 58,
                            child: IconButton.filledTonal(
                              onPressed: _seconds == 0 ? null : _finish,
                              style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.08),
                                  foregroundColor: Colors.white),
                              icon: const Icon(Icons.stop_rounded),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                          _running
                              ? 'Pause anytime · lap marker available'
                              : 'Tap play to start tracking',
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      if (_laps.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(18)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Lap markers',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 10),
                              ...List.generate(_laps.length, (index) {
                                final split = index == 0
                                    ? _laps[index]
                                    : _laps[index] - _laps[index - 1];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 7),
                                  child: Row(
                                    children: [
                                      Text('Lap ${index + 1}',
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12)),
                                      const Spacer(),
                                      Text(_formatClock(split),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveMetric extends StatelessWidget {
  const _LiveMetric(
      {required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 11.5,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900)),
              if (unit.isNotEmpty)
                TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}
