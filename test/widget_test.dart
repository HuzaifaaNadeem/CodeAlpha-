import 'package:flashcard_quiz_app/app.dart';
import 'package:flashcard_quiz_app/features/flashcards/domain/entities/deck.dart';
import 'package:flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders the bright flashcard home screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          decksProvider.overrideWith((ref) async => <Deck>[]),
        ],
        child: const FlashcardQuizApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Fliply'), findsOneWidget);
    expect(find.text('Make studying\nfeel easy.'), findsOneWidget);
    expect(find.text('New deck'), findsOneWidget);
  });
}
