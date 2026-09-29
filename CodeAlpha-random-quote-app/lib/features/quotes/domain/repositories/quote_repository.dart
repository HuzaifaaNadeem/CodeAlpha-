import '../entities/quote_item.dart';

abstract class QuoteRepository {
  Future<List<QuoteItem>> getQuotes();

  Future<Set<String>> getFavoriteIds();

  Future<void> saveFavoriteIds(Set<String> ids);
}
