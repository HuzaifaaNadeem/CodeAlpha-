import '../../domain/entities/quote_item.dart';
import '../../domain/repositories/quote_repository.dart';
import '../datasources/favorites_data_source.dart';
import '../datasources/local_quote_data_source.dart';

class QuoteRepositoryImpl implements QuoteRepository {
  QuoteRepositoryImpl({
    required LocalQuoteDataSource localDataSource,
    required FavoritesDataSource favoritesDataSource,
  })  : _localDataSource = localDataSource,
        _favoritesDataSource = favoritesDataSource;

  final LocalQuoteDataSource _localDataSource;
  final FavoritesDataSource _favoritesDataSource;

  @override
  Future<List<QuoteItem>> getQuotes() async {
    return _localDataSource.loadQuotes();
  }

  @override
  Future<Set<String>> getFavoriteIds() {
    return _favoritesDataSource.loadFavoriteIds();
  }

  @override
  Future<void> saveFavoriteIds(Set<String> ids) {
    return _favoritesDataSource.saveFavoriteIds(ids);
  }
}
