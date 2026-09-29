import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/workout_entry.dart';
import 'workout_visuals.dart';

class WorkoutTile extends StatelessWidget {
  const WorkoutTile({
    super.key,
    required this.workout,
    this.onEdit,
    this.onDelete,
  });

  final WorkoutEntry workout;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = workoutColor(workout.type);
    final hour =
        workout.startedAt.hour % 12 == 0 ? 12 : workout.startedAt.hour % 12;
    final minute = workout.startedAt.minute.toString().padLeft(2, '0');
    final suffix = workout.startedAt.hour >= 12 ? 'PM' : 'AM';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(workoutIcon(workout.type), color: color, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(workout.type,
                            style: Theme.of(context).textTheme.titleMedium)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(99)),
                      child: Text(workout.intensity,
                          style: TextStyle(
                              color: color,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$hour:$minute $suffix · ${workout.durationMinutes} min · ${workout.calories} kcal',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 11.5),
                ),
                if (workout.distanceKm > 0) ...[
                  const SizedBox(height: 3),
                  Text('${workout.distanceKm.toStringAsFixed(2)} km',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800)),
                ],
                if (workout.notes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(workout.notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 10.5)),
                ],
              ],
            ),
          ),
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              tooltip: 'Activity options',
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit?.call();
                } else if (value == 'delete') {
                  onDelete?.call();
                }
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_rounded, size: 19),
                      SizedBox(width: 10),
                      Text('Edit')
                    ]),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 19, color: AppTheme.coral),
                      SizedBox(width: 10),
                      Text('Delete')
                    ]),
                  ),
              ],
              icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.muted),
            ),
          ],
        ],
      ),
    );
  }
}
