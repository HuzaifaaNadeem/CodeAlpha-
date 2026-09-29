import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AppBrand extends StatelessWidget {
  const AppBrand({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 34 : 40,
          height: compact ? 34 : 40,
          decoration: BoxDecoration(
            color: AppTheme.ink,
            borderRadius: BorderRadius.circular(compact ? 11 : 13),
          ),
          child: const Icon(
            Icons.format_quote_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QuoteSpark',
              style: TextStyle(
                fontSize: 19,
                letterSpacing: -0.55,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
            if (!compact)
              const Text(
                'SIGNATURE',
                style: TextStyle(
                  fontSize: 8.5,
                  height: 1.1,
                  letterSpacing: 1.35,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.mutedInk,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
