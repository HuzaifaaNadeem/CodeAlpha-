import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CardStack extends StatelessWidget {
  const CardStack({
    super.key,
    required this.child,
    this.height = 410,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Transform.translate(
          offset: const Offset(0, 22),
          child: Transform.scale(
            scale: 0.90,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFFDCD7FF),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 11),
          child: Transform.scale(
            scale: 0.955,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFFE9E6FF),
                borderRadius: BorderRadius.circular(32),
                border:
                    Border.all(color: AppTheme.purple.withValues(alpha: 0.08)),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
