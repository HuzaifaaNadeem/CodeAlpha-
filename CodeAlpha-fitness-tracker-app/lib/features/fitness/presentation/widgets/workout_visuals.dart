import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

IconData workoutIcon(String type) {
  switch (type) {
    case 'Running':
      return Icons.directions_run_rounded;
    case 'Walking':
      return Icons.directions_walk_rounded;
    case 'Cycling':
      return Icons.directions_bike_rounded;
    case 'Gym':
    case 'Strength':
      return Icons.fitness_center_rounded;
    case 'Yoga':
    case 'Pilates':
      return Icons.self_improvement_rounded;
    case 'Swimming':
      return Icons.pool_rounded;
    case 'Cardio':
      return Icons.monitor_heart_rounded;
    case 'HIIT':
      return Icons.bolt_rounded;
    case 'Hiking':
      return Icons.terrain_rounded;
    case 'Rowing':
      return Icons.rowing_rounded;
    default:
      return Icons.sports_gymnastics_rounded;
  }
}

Color workoutColor(String type) {
  switch (type) {
    case 'Running':
      return AppTheme.coral;
    case 'Walking':
      return AppTheme.primary;
    case 'Cycling':
      return AppTheme.blue;
    case 'Gym':
      return AppTheme.amber;
    case 'Strength':
      return const Color(0xFFBA7D20);
    case 'Yoga':
      return const Color(0xFF8A68C9);
    case 'Pilates':
      return const Color(0xFF9A6CCB);
    case 'Swimming':
      return const Color(0xFF28A9C7);
    case 'Cardio':
      return const Color(0xFFE35B86);
    case 'HIIT':
      return const Color(0xFFEE5B43);
    case 'Hiking':
      return const Color(0xFF6C8D39);
    case 'Rowing':
      return const Color(0xFF4B7FC9);
    default:
      return AppTheme.primary;
  }
}
