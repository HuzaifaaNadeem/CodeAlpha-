import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 38 : 44,
          height: compact ? 38 : 44,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(compact ? 13 : 15),
          ),
          child: const Icon(Icons.translate_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 11),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lingua',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: compact ? 19 : 22,
                    letterSpacing: -0.4,
                  ),
            ),
            Text(
              'SIGNATURE LEARNING',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 9.5,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
