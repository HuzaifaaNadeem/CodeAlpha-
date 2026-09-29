import 'package:codealpha_random_quote_app/features/quotes/data/datasources/local_quote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundled quote library is non-empty and categorized', () {
    const source = LocalQuoteDataSource();
    final quotes = source.loadQuotes();

    expect(quotes.length, greaterThanOrEqualTo(20));
    expect(quotes.every((quote) => quote.text.isNotEmpty), isTrue);
    expect(quotes.every((quote) => quote.author.isNotEmpty), isTrue);
    expect(quotes.every((quote) => quote.category.isNotEmpty), isTrue);
  });
}
