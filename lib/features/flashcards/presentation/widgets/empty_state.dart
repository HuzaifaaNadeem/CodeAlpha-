import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 410),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 108,
                    height: 92,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  Transform.rotate(
                    angle: -0.12,
                    child: Container(
                      width: 68,
                      height: 78,
                      decoration: BoxDecoration(
                        color: AppTheme.yellow,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(12, -3),
                    child: Container(
                      width: 68,
                      height: 78,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.ink.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 31, color: AppTheme.purple),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 9),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
