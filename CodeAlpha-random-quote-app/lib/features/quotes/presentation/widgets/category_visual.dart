import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CategoryVisual {
  const CategoryVisual({
    required this.color,
    required this.softColor,
    required this.icon,
  });

  final Color color;
  final Color softColor;
  final IconData icon;

  static CategoryVisual forName(String category) {
    switch (category) {
      case 'Motivation':
        return const CategoryVisual(
          color: AppTheme.primary,
          softColor: Color(0xFFECE9FF),
          icon: Icons.bolt_rounded,
        );
      case 'Wisdom':
        return const CategoryVisual(
          color: AppTheme.sky,
          softColor: Color(0xFFE9F4FE),
          icon: Icons.psychology_alt_rounded,
        );
      case 'Focus':
        return const CategoryVisual(
          color: AppTheme.amber,
          softColor: Color(0xFFFFF4D9),
          icon: Icons.center_focus_strong_rounded,
        );
      case 'Courage':
        return const CategoryVisual(
          color: AppTheme.coral,
          softColor: Color(0xFFFFECEA),
          icon: Icons.shield_rounded,
        );
      case 'Growth':
        return const CategoryVisual(
          color: AppTheme.mint,
          softColor: Color(0xFFE5F7F1),
          icon: Icons.trending_up_rounded,
        );
      case 'Life':
        return const CategoryVisual(
          color: AppTheme.rose,
          softColor: Color(0xFFF9EAF4),
          icon: Icons.favorite_outline_rounded,
        );
      case 'Action':
        return const CategoryVisual(
          color: Color(0xFFEA7D42),
          softColor: Color(0xFFFFEFE4),
          icon: Icons.rocket_launch_rounded,
        );
      default:
        return const CategoryVisual(
          color: AppTheme.primary,
          softColor: Color(0xFFECE9FF),
          icon: Icons.auto_awesome_rounded,
        );
    }
  }
}
