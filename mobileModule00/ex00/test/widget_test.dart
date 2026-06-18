// This is a basic Flutter widget test for the ex00 display.
//
// It verifies that the initial Text and the ElevatedButton render, and that
// tapping the button does not throw.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ex00/main.dart';

void main() {
  testWidgets('Displays initial text and button', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify the initial display text and the button are shown.
    expect(find.text('A basic display'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Tapping the button does not throw', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap the button and pump a frame; this must not raise an exception.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Tapping logs "Button pressed"', (tester) async {
    final logs = <String>[];
    final original = debugPrint;
    // Restore debugPrint within the test body (try/finally) rather than via
    // addTearDown: the test framework asserts foundation debug vars are unset
    // before tear-down callbacks run.
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };
    try {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
    } finally {
      debugPrint = original;
    }

    expect(logs, contains('Button pressed'));
  });

  testWidgets('No overflow on a narrow surface', (tester) async {
    tester.view.physicalSize = const Size(200, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());

    expect(tester.takeException(), isNull);
  });
}
