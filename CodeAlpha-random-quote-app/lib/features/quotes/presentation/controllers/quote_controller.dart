import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/favorites_data_source.dart';
import '../../data/datasources/local_quote_data_source.dart';
import '../../data/repositories/quote_repository_impl.dart';
import '../../domain/entities/quote_item.dart';
import '../../domain/repositories/quote_repository.dart';

final localQuoteDataSourceProvider = Provider<LocalQuoteDataSource>(
  (ref) => const LocalQuoteDataSource(),
);

final favoritesDataSourceProvider = Provider<FavoritesDataSource>(
  (ref) => FavoritesDataSource(),
);

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  return QuoteRepositoryImpl(
    localDataSource: ref.watch(localQuoteDataSourceProvider),
    favoritesDataSource: ref.watch(favoritesDataSourceProvider),
  );
});

final quoteControllerProvider =
    StateNotifierProvider<QuoteController, QuoteState>((ref) {
  final controller = QuoteController(
    repository: ref.watch(quoteRepositoryProvider),
  );
  controller.initialize();
  return controller;
});

class QuoteState {
  const QuoteState({
    this.isLoading = true,
    this.quotes = const [],
    this.currentQuote,
    this.selectedCategory = 'All',
    this.favoriteIds = const {},
  });

  final bool isLoading;
  final List<QuoteItem> quotes;
  final QuoteItem? currentQuote;
  final String selectedCategory;
  final Set<String> favoriteIds;

  List<String> get categories {
    final values = quotes.map((quote) => quote.category).toSet().toList()
      ..sort();
    return ['All', ...values];
  }

  List<QuoteItem> get filteredQuotes {
    if (selectedCategory == 'All') {
      return quotes;
    }

    return quotes.where((quote) => quote.category == selectedCategory).toList();
  }

  List<QuoteItem> get favoriteQuotes {
    return quotes.where((quote) => favoriteIds.contains(quote.id)).toList();
  }

  bool isFavorite(QuoteItem quote) => favoriteIds.contains(quote.id);

  QuoteState copyWith({
    bool? isLoading,
    List<QuoteItem>? quotes,
    QuoteItem? currentQuote,
    String? selectedCategory,
    Set<String>? favoriteIds,
  }) {
    return QuoteState(
      isLoading: isLoading ?? this.isLoading,
      quotes: quotes ?? this.quotes,
      currentQuote: currentQuote ?? this.currentQuote,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }
}

class QuoteController extends StateNotifier<QuoteState> {
  QuoteController({
    required QuoteRepository repository,
    Random? random,
  })  : _repository = repository,
        _random = random ?? Random(),
        super(const QuoteState());

  final QuoteRepository _repository;
  final Random _random;

  Future<void> initialize() async {
    final quotes = await _repository.getQuotes();
    final favoriteIds = await _repository.getFavoriteIds();
    final firstQuote =
        quotes.isEmpty ? null : quotes[_random.nextInt(quotes.length)];

    state = QuoteState(
      isLoading: false,
      quotes: quotes,
      currentQuote: firstQuote,
      favoriteIds: favoriteIds,
    );
  }

  void newQuote() {
    final pool = state.filteredQuotes;
    if (pool.isEmpty) {
      return;
    }

    if (pool.length == 1) {
      state = state.copyWith(currentQuote: pool.first);
      return;
    }

    QuoteItem next;
    do {
      next = pool[_random.nextInt(pool.length)];
    } while (next.id == state.currentQuote?.id);

    state = state.copyWith(currentQuote: next);
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    newQuote();
  }

  Future<void> toggleFavorite(QuoteItem quote) async {
    final updated = Set<String>.from(state.favoriteIds);

    if (updated.contains(quote.id)) {
      updated.remove(quote.id);
    } else {
      updated.add(quote.id);
    }

    state = state.copyWith(favoriteIds: updated);
    await _repository.saveFavoriteIds(updated);
  }
}
