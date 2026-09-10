import 'package:dyatel/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// A phone-sized surface, so nothing the tests tap sits off-screen.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DyatelApp());
    await tester.pumpAndSettle();
  }

  testWidgets('starts on the empty state and generates a number', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Random Number'), findsOneWidget);
    expect(find.text('Ready when you are'), findsOneWidget);
    expect(find.text('Generate number'), findsOneWidget);

    await tester.tap(find.text('Generate number'));
    await tester.pumpAndSettle();

    expect(find.text('Ready when you are'), findsNothing);
    expect(find.text('Generate new'), findsOneWidget);
    expect(find.text('Listen'), findsOneWidget);
  });

  testWidgets('hiding blurs the result and offers Reveal', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate number'));
    await tester.pumpAndSettle();

    expect(find.text('Listen before you reveal'), findsOneWidget);
    expect(find.text('Reveal'), findsOneWidget);

    await tester.tap(find.text('Reveal'));
    await tester.pumpAndSettle();

    expect(find.text('Listen before you reveal'), findsNothing);
    expect(find.text('Generate new'), findsOneWidget);
  });

  testWidgets('the language sheet opens and applies a choice', (tester) async {
    await pumpApp(tester);

    expect(find.text('Portuguese (Brazil)'), findsOneWidget);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    expect(find.text('Choose language'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'german');
    await tester.pumpAndSettle();

    await tester.tap(find.text('German (Germany)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('German (Germany)'), findsOneWidget);

    // Let the best-effort "stop playback" guard timer expire before teardown.
    await tester.pump(const Duration(seconds: 3));
  });
}
