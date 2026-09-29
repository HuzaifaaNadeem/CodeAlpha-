import 'package:codealpha_random_quote_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('QuoteSpark signature home loads', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: QuoteSparkApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('QuoteSpark'), findsOneWidget);
    expect(find.text('SIGNATURE'), findsOneWidget);
    expect(find.text('SHIFT YOUR MOOD'), findsOneWidget);
    expect(find.byKey(const Key('newQuoteButton')), findsOneWidget);
    expect(find.text('New Quote'), findsOneWidget);
  });
}
