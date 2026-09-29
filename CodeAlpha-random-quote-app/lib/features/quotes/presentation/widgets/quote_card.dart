import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/quote_item.dart';
import 'category_visual.dart';

/// The signature quote surface used on the home screen.
///
/// Actions intentionally live outside this card in the bottom dock so the
/// quote remains the visual focus.
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    required this.isFavorite,
  });

  final QuoteItem quote;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = CategoryVisual.forName(quote.category);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final horizontalPadding = compact ? 24.0 : 38.0;
        final quoteSize = compact ? 27.0 : 34.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 390),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                visual.softColor.withValues(alpha: 0.56),
                Colors.white,
              ],
              stops: const [0.0, 0.68, 1.0],
            ),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: visual.color.withValues(alpha: 0.12),
            ),
            boxShadow: AppTheme.premiumShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(33),
            child: Stack(
              children: [
                Positioned(
                  top: -78,
                  right: -66,
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: visual.color.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Positioned(
                  left: -54,
                  bottom: -78,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: visual.color.withValues(alpha: 0.045),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    compact ? 28 : 38,
                    horizontalPadding,
                    compact ? 28 : 38,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          _MoodMark(
                            category: quote.category,
                            color: visual.color,
                            icon: visual.icon,
                          ),
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: isFavorite
                                ? Container(
                                    key: const ValueKey('saved'),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.72),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.favorite_rounded,
                                          size: 14,
                                          color: AppTheme.coral,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Saved',
                                          style: TextStyle(
                                            color: AppTheme.ink,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(
                                    key: ValueKey('not-saved'),
                                  ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 34 : 48),
                      Text(
                        '“',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: compact ? 54 : 64,
                          height: 0.6,
                          fontWeight: FontWeight.w700,
                          color: visual.color.withValues(alpha: 0.9),
                        ),
                      ),
                      SizedBox(height: compact ? 22 : 28),
                      Text(
                        quote.text,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: quoteSize,
                          height: 1.38,
                          letterSpacing: compact ? -0.7 : -0.95,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                      SizedBox(height: compact ? 32 : 40),
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 2,
                            decoration: BoxDecoration(
                              color: visual.color,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              quote.author,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.ink,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoodMark extends StatelessWidget {
  const _MoodMark({
    required this.category,
    required this.color,
    required this.icon,
  });

  final String category;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            category,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
