import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/quote_item.dart';
import '../controllers/quote_controller.dart';
import '../widgets/category_selector.dart';
import '../widgets/category_visual.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QuoteItem> _filteredFavorites(
    List<QuoteItem> favorites,
    String selectedCategory,
  ) {
    final normalized = _query.trim().toLowerCase();

    return favorites.where((quote) {
      final categoryMatches =
          selectedCategory == 'All' || quote.category == selectedCategory;
      final queryMatches = normalized.isEmpty ||
          quote.text.toLowerCase().contains(normalized) ||
          quote.author.toLowerCase().contains(normalized) ||
          quote.category.toLowerCase().contains(normalized);

      return categoryMatches && queryMatches;
    }).toList();
  }

  List<String> _categories(List<QuoteItem> favorites) {
    final categories = favorites.map((quote) => quote.category).toSet().toList()
      ..sort();
    return ['All', ...categories];
  }

  Future<void> _copyQuote(BuildContext context, QuoteItem quote) async {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quoteControllerProvider);
    final controller = ref.read(quoteControllerProvider.notifier);
    final favorites = state.favoriteQuotes;
    final categories = _categories(favorites);
    final selectedCategory =
        categories.contains(_selectedCategory) ? _selectedCategory : 'All';
    final visible = _filteredFavorites(favorites, selectedCategory);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saved',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              favorites.length == 1
                  ? '1 thought in your collection'
                  : '${favorites.length} thoughts in your collection',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 10.5,
                  ),
            ),
          ],
        ),
      ),
      body: favorites.isEmpty
          ? const _FavoritesEmptyState()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search saved quotes',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 7),
                  child: Row(
                    children: [
                      Text(
                        'FILTER BY MOOD',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${visible.length} showing',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.ink,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                CategorySelector(
                  categories: categories,
                  selected: selectedCategory,
                  onSelected: (value) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = value);
                  },
                ),
                const SizedBox(height: 8),
                const Divider(),
                Expanded(
                  child: visible.isEmpty
                      ? _NoSearchResults(
                          query: _query,
                          category: selectedCategory,
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final twoColumns = constraints.maxWidth >= 820;
                            const spacing = 14.0;
                            final horizontalPadding =
                                constraints.maxWidth >= 720 ? 24.0 : 16.0;
                            final itemWidth = twoColumns
                                ? (constraints.maxWidth -
                                        (horizontalPadding * 2) -
                                        spacing) /
                                    2
                                : constraints.maxWidth -
                                    (horizontalPadding * 2);

                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                16,
                                horizontalPadding,
                                32,
                              ),
                              child: Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: [
                                  for (final quote in visible)
                                    SizedBox(
                                      width: itemWidth,
                                      child: _FavoriteCard(
                                        quote: quote,
                                        onRemove: () async {
                                          await HapticFeedback.selectionClick();
                                          await controller
                                              .toggleFavorite(quote);
                                        },
                                        onCopy: () =>
                                            _copyQuote(context, quote),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.quote,
    required this.onRemove,
    required this.onCopy,
  });

  final QuoteItem quote;
  final VoidCallback onRemove;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = CategoryVisual.forName(quote.category);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07171821),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: visual.softColor.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(visual.icon, size: 13, color: visual.color),
                    const SizedBox(width: 5),
                    Text(
                      quote.category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: visual.color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Remove from saved',
                onPressed: onRemove,
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.coral,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '“${quote.text}”',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 17,
              height: 1.48,
              letterSpacing: -0.25,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            quote.author,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: AppTheme.outline,
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.ink,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: AppTheme.primary,
                  size: 31,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your collection is quiet',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Save the thoughts you want to return to. They stay privately on this device.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({
    required this.query,
    required this.category,
  });

  final String query;
  final String category;

  @override
  Widget build(BuildContext context) {
    final detail = query.trim().isNotEmpty
        ? 'No saved quote matches “${query.trim()}”.'
        : 'No saved quote is available in $category yet.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: AppTheme.mutedInk,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              'Nothing found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
