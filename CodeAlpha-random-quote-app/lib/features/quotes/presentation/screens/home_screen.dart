import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/quote_item.dart';
import '../controllers/quote_controller.dart';
import '../widgets/app_brand.dart';
import '../widgets/category_selector.dart';
import '../widgets/category_visual.dart';
import '../widgets/quote_card.dart';
import 'favorites_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _copyQuote(
    BuildContext context,
    QuoteItem quote,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: '“${quote.text}” — ${quote.author}'),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 19,
              ),
              SizedBox(width: 9),
              Text('Quote copied'),
            ],
          ),
        ),
      );
  }

  void _openSaved(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FavoritesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quoteControllerProvider);
    final controller = ref.read(quoteControllerProvider.notifier);
    final quote = state.currentQuote;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.space): () {
          controller.newQuote();
          HapticFeedback.lightImpact();
        },
        const SingleActivator(LogicalKeyboardKey.keyS): () {
          if (quote != null) {
            controller.toggleFavorite(quote);
            HapticFeedback.selectionClick();
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyC): () {
          if (quote != null) {
            _copyQuote(context, quote);
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppTheme.canvas,
          body: SafeArea(
            child: Column(
              children: [
                _SignatureHeader(
                  savedCount: state.favoriteIds.length,
                  onSavedPressed: () => _openSaved(context),
                ),
                _MoodRail(
                  categories: state.categories,
                  selected: state.selectedCategory,
                  onSelected: (category) async {
                    await HapticFeedback.selectionClick();
                    controller.selectCategory(category);
                  },
                ),
                Expanded(
                  child: state.isLoading
                      ? const _LoadingStage()
                      : _QuoteStage(
                          state: state,
                        ),
                ),
                if (!state.isLoading && quote != null)
                  _ActionDock(
                    isFavorite: state.isFavorite(quote),
                    onNewQuote: () async {
                      await HapticFeedback.lightImpact();
                      controller.newQuote();
                    },
                    onFavorite: () async {
                      await HapticFeedback.selectionClick();
                      await controller.toggleFavorite(quote);
                    },
                    onCopy: () => _copyQuote(context, quote),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignatureHeader extends StatelessWidget {
  const _SignatureHeader({
    required this.savedCount,
    required this.onSavedPressed,
  });

  final int savedCount;
  final VoidCallback onSavedPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 14, 10),
      child: Row(
        children: [
          const AppBrand(),
          const Spacer(),
          Tooltip(
            message: 'Saved quotes',
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              child: InkWell(
                onTap: onSavedPressed,
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: AppTheme.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        savedCount > 0
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 19,
                        color: savedCount > 0 ? AppTheme.coral : AppTheme.ink,
                      ),
                      if (savedCount > 0) ...[
                        const SizedBox(width: 7),
                        Text(
                          '$savedCount',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontSize: 12.5),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodRail extends StatelessWidget {
  const _MoodRail({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: AppTheme.canvas,
        border: Border(
          bottom: BorderSide(color: AppTheme.outline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 3, 20, 9),
            child: Row(
              children: [
                Text(
                  'SHIFT YOUR MOOD',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mutedInk,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                ),
                const Spacer(),
                Text(
                  selected,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.ink,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          CategorySelector(
            categories: categories,
            selected: selected,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _QuoteStage extends StatelessWidget {
  const _QuoteStage({required this.state});

  final QuoteState state;

  @override
  Widget build(BuildContext context) {
    final quote = state.currentQuote;

    if (quote == null) {
      return const _EmptyStage();
    }

    final index = state.filteredQuotes.indexWhere(
      (item) => item.id == quote.id,
    );
    final position = index < 0 ? 1 : index + 1;
    final count = state.filteredQuotes.length;
    final visual = CategoryVisual.forName(quote.category);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHeight = constraints.maxHeight < 560;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            18,
            compactHeight ? 18 : 28,
            18,
            compactHeight ? 18 : 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _stageTitle(state.selectedCategory),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.mutedInk,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: visual.softColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '${position.toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: visual.color,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compactHeight ? 12 : 17),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final offset = Tween<Offset>(
                        begin: const Offset(0.035, 0.02),
                        end: Offset.zero,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offset,
                          child: child,
                        ),
                      );
                    },
                    child: QuoteCard(
                      key: ValueKey(quote.id),
                      quote: quote,
                      isFavorite: state.isFavorite(quote),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _stageTitle(String selectedCategory) {
    if (selectedCategory == 'All') {
      return 'A thought for this moment';
    }
    return 'A $selectedCategory thought for this moment';
  }
}

class _ActionDock extends StatelessWidget {
  const _ActionDock({
    required this.isFavorite,
    required this.onNewQuote,
    required this.onFavorite,
    required this.onCopy,
  });

  final bool isFavorite;
  final VoidCallback onNewQuote;
  final VoidCallback onFavorite;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppTheme.canvas.withValues(alpha: 0.98),
        border: const Border(
          top: BorderSide(color: AppTheme.outline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Row(
              children: [
                _DockButton(
                  tooltip: 'Copy quote',
                  icon: Icons.copy_rounded,
                  onPressed: onCopy,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('newQuoteButton'),
                    onPressed: onNewQuote,
                    icon: const Icon(Icons.shuffle_rounded, size: 19),
                    label: const Text('New Quote'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.ink,
                      minimumSize: const Size(0, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _DockButton(
                  tooltip: isFavorite ? 'Remove from saved' : 'Save quote',
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: isFavorite ? AppTheme.coral : AppTheme.ink,
                  onPressed: onFavorite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.outline),
            ),
            child: Icon(
              icon,
              size: 21,
              color: iconColor ?? AppTheme.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingStage extends StatelessWidget {
  const _LoadingStage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Container(
                height: 16,
                width: 170,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSoft,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 410,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: AppTheme.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStage extends StatelessWidget {
  const _EmptyStage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No quote here yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Slide to another mood to keep exploring.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
