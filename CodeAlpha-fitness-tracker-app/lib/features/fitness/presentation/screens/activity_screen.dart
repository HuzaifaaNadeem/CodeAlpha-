import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../domain/entities/workout_catalog.dart';
import '../../domain/entities/workout_entry.dart';
import '../controllers/fitness_controller.dart';
import '../widgets/workout_tile.dart';
import 'quick_add_sheet.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  String _filter = 'All';
  String _query = '';

  List<String> get _filters => [
        'All',
        ...workoutCatalog.map((item) => item.name),
      ];

  Future<void> _deleteWorkout(WorkoutEntry workout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete activity?'),
        content: Text(
          'Remove this ${workout.type.toLowerCase()} session from your history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.coral),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(fitnessControllerProvider.notifier).deleteWorkout(workout);
    }
  }

  void _editWorkout(WorkoutEntry workout) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddSheet(initial: workout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fitnessControllerProvider);
    final controller = ref.read(fitnessControllerProvider.notifier);

    if (state.isLoading || state.snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final workouts = <WorkoutEntry>[];
    for (final record in state.snapshot!.records.values) {
      workouts.addAll(record.workouts);
    }
    workouts.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    final normalizedQuery = _query.trim().toLowerCase();
    final filtered = workouts.where((item) {
      final matchesFilter = _filter == 'All' || item.type == _filter;
      final matchesSearch = normalizedQuery.isEmpty ||
          item.type.toLowerCase().contains(normalizedQuery) ||
          item.intensity.toLowerCase().contains(normalizedQuery) ||
          item.notes.toLowerCase().contains(normalizedQuery) ||
          '${item.durationMinutes}'.contains(normalizedQuery) ||
          '${item.calories}'.contains(normalizedQuery);
      return matchesFilter && matchesSearch;
    }).toList();

    final totalMinutes = workouts.fold<int>(
      0,
      (sum, item) => sum + item.durationMinutes,
    );
    final totalCalories = workouts.fold<int>(
      0,
      (sum, item) => sum + item.calories,
    );
    final totalDistance = workouts.fold<double>(
      0,
      (sum, item) => sum + item.distanceKm,
    );

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activity',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your training, beautifully organized.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Add activity',
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const QuickAddSheet(),
                      ),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                PremiumCard(
                  backgroundColor: const Color(0xFFF0F7F4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryStat(
                          value: '${workouts.length}',
                          label: 'Sessions',
                        ),
                      ),
                      Container(width: 1, height: 44, color: AppTheme.outline),
                      Expanded(
                        child: _SummaryStat(
                          value: '$totalMinutes',
                          label: 'Minutes',
                        ),
                      ),
                      Container(width: 1, height: 44, color: AppTheme.outline),
                      Expanded(
                        child: _SummaryStat(
                          value: '$totalCalories',
                          label: 'kcal',
                        ),
                      ),
                      Container(width: 1, height: 44, color: AppTheme.outline),
                      Expanded(
                        child: _SummaryStat(
                          value: totalDistance > 0
                              ? totalDistance.toStringAsFixed(1)
                              : '—',
                          label: 'km',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search workouts',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = _filters[index];
                      return ChoiceChip(
                        selected: item == _filter,
                        onSelected: (_) => setState(() => _filter = item),
                        label: Text(item),
                        selectedColor: AppTheme.ink,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.outline),
                        labelStyle: TextStyle(
                          color: item == _filter ? Colors.white : AppTheme.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                if (filtered.isEmpty)
                  PremiumCard(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.history_toggle_off_rounded,
                          color: AppTheme.primary,
                          size: 34,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No matching sessions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try another filter or log a new workout.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                else
                  ...filtered.map(
                    (workout) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: WorkoutTile(
                        workout: workout,
                        onEdit: () => _editWorkout(workout),
                        onDelete: () => _deleteWorkout(workout),
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                TextButton.icon(
                  onPressed: () async {
                    await controller.addSteps(1000);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('1,000 steps added to today'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.directions_walk_rounded),
                  label: const Text('Log 1,000 manual steps'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: AppTheme.primary),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
