import 'package:codealpha_fitness_tracker_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PulseFit MAX shell loads with primary navigation',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PulseFitApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Train'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Start workout'), findsOneWidget);
  });
}
