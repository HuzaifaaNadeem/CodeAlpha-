import 'package:codealpha_language_learning_app/app.dart';
import 'package:codealpha_language_learning_app/features/learning/domain/entities/progress_state.dart';
import 'package:codealpha_language_learning_app/features/learning/domain/repositories/progress_repository.dart';
import 'package:codealpha_language_learning_app/features/learning/presentation/providers/learning_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProgressRepository implements ProgressRepository {
  ProgressState state = ProgressState.empty();

  @override
  Future<ProgressState> load() async => state;

  @override
  Future<void> save(ProgressState state) async {
    this.state = state;
  }

  @override
  Future<void> reset() async {
    state = ProgressState.empty();
  }
}

void main() {
  testWidgets('Lingua home screen loads', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider
              .overrideWithValue(_FakeProgressRepository()),
        ],
        child: const LinguaApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Lingua'), findsOneWidget);
    expect(find.textContaining('Ready for'), findsOneWidget);
    expect(find.text('Continue learning'), findsOneWidget);
  });
}
