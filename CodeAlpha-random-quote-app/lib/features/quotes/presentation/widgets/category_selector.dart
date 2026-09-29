import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'category_visual.dart';

/// A compact, horizontally scrollable mood rail.
///
/// The selected mood is automatically brought toward the center so the
/// interaction feels closer to a native segmented carousel than a chip list.
class CategorySelector extends StatefulWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _centerSelectedMood();
    }
  }

  void _centerSelectedMood() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients || widget.categories.isEmpty) {
        return;
      }

      final index = widget.categories.indexOf(widget.selected);
      if (index < 0) {
        return;
      }

      // Mood items are intentionally compact. This approximation is enough to
      // keep the active segment comfortably within the visible rail.
      final desired = (index * 92.0) - 70.0;
      final target = desired
          .clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          )
          .toDouble();

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final selected = category == widget.selected;
          final visual = CategoryVisual.forName(category);

          return Semantics(
            selected: selected,
            button: true,
            label: '$category mood',
            child: InkWell(
              onTap: () => widget.onSelected(category),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? (category == 'All' ? AppTheme.ink : visual.color)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? Colors.transparent : AppTheme.outline,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: (category == 'All'
                                    ? AppTheme.ink
                                    : visual.color)
                                .withValues(alpha: 0.16),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : const [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category == 'All'
                          ? Icons.auto_awesome_rounded
                          : visual.icon,
                      size: 16,
                      color: selected ? Colors.white : visual.color,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      category,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: selected ? Colors.white : AppTheme.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
